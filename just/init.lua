local just = {}

local mouse = {
	down = {},
	pressed = {},
	released = {},
	x = 0, y = 0,
	px = 0, py = 0,
	dx = 0, dy = 0,
	scroll_delta = 0,
}
just.mouse = mouse

just.entered_id = false
just.exited_id = false
just.height = 0

local next_id
local over_id

local hover_ids = {}
local next_hover_ids = {}

local containers = {}
local container_overs = {}
local zindexes = {}
local last_zindex = 0

function just.set_id(id)
	next_id = id
end

function just.get_id(id)
	id = next_id or id
	next_id = nil
	return id
end

local line_c = 0
local line_h = 0
local line_w = 0

local is_row = false
local is_sameline = false

function just.is_over(w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= x and x <= w and 0 <= y and y <= h
end

function just.row(state)
	is_row = false
	just.next()
	is_row = state
end

function just.next(w, h)
	w, h = w or 0, h or 0
	line_w = line_c + w
	line_h = line_c > 0 and math.max(line_h, h) or h
	is_sameline = false
	if is_row then
		love.graphics.translate(w, 0)
		line_c = line_w
	else
		love.graphics.translate(-line_c, line_h)
		line_c = 0
		just.height = just.height + line_h
	end
end

function just.sameline()
	assert(not is_row, "just.sameline() can not be called in a row mode")
	assert(not is_sameline, "just.sameline() called twice")
	is_sameline = true
	line_c = line_w
	love.graphics.translate(line_c, -line_h)
	just.height = just.height - line_h
end

function just.emptyline(h)
	just.next(0, h)
end

function just.indent(w)
	if line_c == 0 then
		line_h = 0
	end
	just.next(w, line_h)
	if not is_row then
		just.sameline()
	end
end

function just.text(text, limit)
	limit = limit or math.huge
	local font = love.graphics.getFont()
	love.graphics.printf(text, 0, 0, limit, "left")
	local w, wrapped = font:getWrap(text, limit)
	just.next(w, font:getHeight() * #wrapped)
end

local function clear_table(t)
	for k in pairs(t) do
		t[k] = nil
	end
end

function just._end()
	assert(#containers == 0, "container not closed")

	clear_table(mouse.pressed)
	clear_table(mouse.released)
	clear_table(zindexes)

	local any_mouse_over = next(next_hover_ids)

	just.entered_id, just.exited_id = false, false
	just.height = 0
	last_zindex = 0
	line_c = 0
	mouse.scroll_delta = 0
	mouse.captured = any_mouse_over or just.active_id
	mouse.dx, mouse.dy = mouse.x - mouse.px, mouse.y - mouse.py
	mouse.px, mouse.py = mouse.x, mouse.y

	clear_table(hover_ids)
	hover_ids, next_hover_ids = next_hover_ids, hover_ids

	if not any_mouse_over then
		over_id = nil
	end
	any_mouse_over = false
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

function just.mouse_over(id, over, group)
	if not zindexes[id] then
		last_zindex = last_zindex + 1
		zindexes[id] = last_zindex
	end

	local next_hover_id = next_hover_ids[group]
	if over and (not next_hover_id or zindexes[id] > zindexes[next_hover_id]) then
		next_hover_ids[group] = id
	end

	local container_over = #container_overs == 0 or container_overs[#container_overs]
	local mouse_over = container_over and id == hover_ids[group]

	if mouse_over and over_id ~= id then
		over_id = id
		just.entered_id = id
	elseif not mouse_over and over_id == id then
		just.exited_id = id
	end

	return mouse_over
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

function just.begin_container_behavior(id, over)
	table.insert(containers, id)
	table.insert(container_overs, over)

	local changed, active, hovered = just.button_behavior(id, over)
	changed = just.active_id == id

	return changed, active, hovered
end

function just.end_container_behavior()
	table.remove(container_overs)
	return table.remove(containers)
end

return just
