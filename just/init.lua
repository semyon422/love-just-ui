local just = {}

local mouse = {
	down = {},
	pressed = {},
	released = {},
	scroll_delta = 0,
	captured = false,
}

just.entered_id = nil
just.exited_id = nil
just.focused_id = nil
just.height = 0

local over_id
local focus_id

local hover_ids = {}
local next_hover_ids = {}

local containers = {}
local container_overs = {}
local zindexes = {}
local last_zindex = 0

local line_c = 0
local line_h = 0
local line_w = 0

local is_row = false
local is_sameline = false

function just.focus(id)
	just.focused_id = id
end

function just.is_over(w, h)
	local mx, my = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local x, y = 0, 0
	if w < 0 then
		x, w = w, x
	end
	if h < 0 then
		y, h = h, y
	end
	return x <= mx and mx <= w and y <= my and my <= h
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

function just.offset(w)
	if not w then
		return line_w
	end
	just.indent(w - line_w)
end

function just.text(text, limit, right)
	local _limit = limit or math.huge
	assert(not right or _limit ~= math.huge)
	local font = love.graphics.getFont()
	love.graphics.printf(text, 0, 0, _limit, right and "right" or "left")
	local w, wrapped = font:getWrap(text, _limit)
	local h = font:getHeight() * #wrapped
	just.next(limit or w, h)
	return limit or w, h
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

	just.entered_id, just.exited_id = nil, nil
	just.height = 0
	last_zindex = 0
	line_c = 0
	mouse.scroll_delta = 0
	mouse.captured = any_mouse_over or just.active_id

	clear_table(hover_ids)
	hover_ids, next_hover_ids = next_hover_ids, hover_ids

	local new_over_id = hover_ids.mouse
	if over_id ~= new_over_id then
		just.exited_id = over_id
		over_id = new_over_id
		just.entered_id = new_over_id
	end
end

function just.mousepressed(_, _, button)
	mouse.down[button] = true
	mouse.pressed[button] = true
	return mouse.captured
end

function just.mousereleased(_, _, button)
	mouse.down[button] = nil
	mouse.released[button] = true
	return mouse.captured
end

function just.mousemoved()
	return mouse.captured
end

function just.wheelmoved(_, y)
	mouse.scroll_delta = y
	return mouse.captured
end

function just.is_container_over(depth)
	local index = #container_overs - (depth or 1) + 1
	return #container_overs == 0 or container_overs[index]
end

function just.mouse_over(id, over, group, new_zindex)
	if not zindexes[id] or new_zindex then
		last_zindex = last_zindex + 1
		zindexes[id] = last_zindex
	end

	local container_over = just.is_container_over()

	local next_hover_id = next_hover_ids[group]
	if over and container_over and (not next_hover_id or zindexes[id] > zindexes[next_hover_id]) then
		next_hover_ids[group] = id
	end

	return container_over and id == hover_ids[group]
end

function just.wheel_over(id, over)
	local d = mouse.scroll_delta
	return just.mouse_over(id, over, "wheel") and d ~= 0 and d
end

function just.button(id, over, button)
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

function just.slider(id, over, pos, value)
	local _, active, hovered = just.button(id, over)

	local new_value = value
	if just.active_id == id then
		new_value = pos
	end

	return value ~= new_value and new_value, active, hovered
end

function just.container(id, over)
	if not id then
		table.remove(container_overs)
		return table.remove(containers)
	end

	table.insert(containers, id)
	table.insert(container_overs, over)

	local changed, active, hovered = just.button(id, over)
	changed = just.active_id == id

	return changed, active, hovered
end

return just
