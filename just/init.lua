local just = {}

just.views = {
	button = require("just.views.button"),
	checkbox = require("just.views.checkbox"),
	slider = require("just.views.slider"),
	text = require("just.views.text"),
	window = require("just.views.window"),
}

local mouse = {
	down = {},
	pressed = {},
	released = {},
	x = 0, y = 0,
	px = 0, py = 0,
	dx = 0, dy = 0,
	scroll_delta = 0,
}

local last_in_rect
local last_window_height
local last_id
local next_id

local containers = {}
local zindexes = {}
local last_zindex = 0
local content_height = 0
local content_heights = {}

function just.set_id(id)
	next_id = id
end

function just.get_id(id)
	if not next_id then
		return id
	end
	id = next_id
	next_id = nil
	return id
end

local line_c = 0
local line_h = 0
local line_w = 0

function just.nextline(w, h)
	line_w, line_h = line_c + w, line_c > 0 and math.max(line_h, h) or h
	love.graphics.translate(-line_c, line_h)
	line_c = 0
	content_height = content_height + line_h
end

function just.sameline()
	line_c = line_w
	love.graphics.translate(line_c, -line_h)
	content_height = content_height - line_h
end

function just.emptyline(h)
	just.nextline(0, h)
end

function just.indent(w)
	if line_c == 0 then
		line_h = 0
	end
	just.nextline(w, line_h)
	just.sameline()
end

local function clear_table(t)
	for k in pairs(t) do
		t[k] = nil
	end
end

local hover_ids = {}
local next_hover_ids = {}

function just._end()
	clear_table(mouse.pressed)
	clear_table(mouse.released)
	clear_table(zindexes)

	last_zindex = 0
	line_c = 0
	mouse.scroll_delta = 0
	mouse.captured = next(hover_ids) or just.active_id
	mouse.dx, mouse.dy = mouse.x - mouse.px, mouse.y - mouse.py
	mouse.px, mouse.py = mouse.x, mouse.y

	clear_table(hover_ids)
	hover_ids, next_hover_ids = next_hover_ids, hover_ids
end

function just.mousepressed(x, y, button)
	mouse.x, mouse.y = x, y
	mouse.down[button] = true
	mouse.pressed[button] = true
	return mouse.captured
end

function just.mousereleased(x, y, button)
	mouse.x, mouse.y = x, y
	mouse.down[button] = nil
	mouse.released[button] = true
	return mouse.captured
end

function just.mousemoved(x, y)
	mouse.x, mouse.y = x, y
	return mouse.captured
end

function just.wheelmoved(x, y)
	mouse.scroll_delta = y
	return mouse.captured
end

local states = {}
local function get_state(id, view)
	local state = states[id]
	if state then
		local mt = getmetatable(state)
		mt.__index = view
		return state
	end
	states[id] = setmetatable({}, {__index = view})
	return states[id]
end

function just.mouse_over(id, over, group)
	if not zindexes[id] then
		last_zindex = last_zindex + 1
		zindexes[id] = last_zindex
	end
	local next_hover_id = next_hover_ids[group]
	if over and (not next_hover_id or zindexes[id] > zindexes[next_hover_id]) then
		next_hover_ids[group] = id
	end
	return over and id == hover_ids[group]
end

function just.button_behavior(id, over, button)
	over = just.mouse_over(id, over, "mouse")
	button = button or next(mouse.pressed) or next(mouse.released) or next(mouse.down)
	if mouse.pressed[button] and over then
		just.active_id = id
	end

	local same_id = just.active_id == id

	local down = mouse.down[button]
	local active = over and same_id and down
	local hovered = over and (same_id or not down)

	local changed
	if same_id and not down then
		changed = over and same_id and button
		just.active_id = nil
	end

	return changed, active, hovered
end

function just.slider_behavior(id, over, pos, value, min, max)
	local _, active, hovered = just.button_behavior(id, over)

	local new_value = value
	if just.active_id == id then
		new_value = min + (max - min) * pos
	end

	return value ~= new_value, new_value, active, hovered
end

function just.wheel_behavior(id, over)
	over = just.mouse_over(id, over, "wheel")
	local changed = over and mouse.scroll_delta ~= 0

	return changed, changed and mouse.scroll_delta or 0
end

function just.button(text)
	local id = just.get_id(text)
	local view = get_state(id, just.views.button)

	last_in_rect = view:is_over(text)
	last_id = id

	local changed, active, hovered = just.button_behavior(id, last_in_rect)
	just.nextline(view:draw(text, active, hovered))

	return changed
end

function just.checkbox(id, out)
	id = just.get_id(id)
	local view = get_state(id, just.views.checkbox)
	local k, t = next(out)

	last_in_rect = view:is_over()
	last_id = id

	local changed, active, hovered = just.button_behavior(id, last_in_rect)
	if changed then
		t[k] = not t[k]
	end
	just.nextline(view:draw(active, hovered, t[k]))

	return changed
end

function just.slider(id, out, min, max, vertical)
	id = just.get_id(id)
	local view = get_state(id, just.views.slider)
	local k, t = next(out)
	local value = t[k]

	last_in_rect = view:is_over()
	last_id = id
	local pos = view:get_pos(vertical)

	local changed, value, active, hovered = just.slider_behavior(id, last_in_rect, pos, value, min, max)
	just.nextline(view:draw(active, hovered, value, min, max, vertical))
	t[k] = value

	return changed
end

function just.text(text)
	local id = just.get_id(text)
	local view = get_state(id, just.views.text)
	just.nextline(view:draw(text, math.huge))
end

function just.window_behavior(id, over)
	over = just.mouse_over(id, over, "mouse")
	if mouse.pressed[1] and over then
		just.active_id = id
	end

	local same_id = just.active_id == id
	if same_id and not mouse.down[1] then
		just.active_id = nil
	end

	return same_id
end

function just.begin_window(id, w, h)
	id = just.get_id(id)
	table.insert(containers, id)

	local view = get_state(id, just.views.window)
	last_in_rect = view:is_over(w, h)
	last_id = id
	last_window_height = h
	content_height = 0

	view:begin_draw(w, h)

	local active = just.window_behavior(id, last_in_rect)
	if not active then
		return 0, 0
	end
	return mouse.dx, mouse.dy
end

function just.end_window()
	local id = table.remove(containers)
	local b = get_state(id, just.views.window)

	content_heights[id] = content_height
	content_height = 0

	b:end_draw()
end

function just.wheelscroll(out, speed)
	local id = last_id
	local content = content_heights[id]
	if content and content <= last_window_height then
		return
	end

	local k, t = next(out)
	local over = just.mouse_over(id, last_in_rect, "wheel")
	if mouse.scroll_delta ~= 0 and over then
		t[k] = math.min(math.max(t[k] + mouse.scroll_delta * (speed or 50), last_window_height - content), 0)
	end
end

return just