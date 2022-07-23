local just = require("just")

local ui = {}

ui.views = {
	button = require("just.views.button"),
	checkbox = require("just.views.checkbox"),
	slider = require("just.views.slider"),
	window = require("just.views.window"),
}

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

local a = {love.math.colorFromBytes(15, 135, 250, 255)}
local h = {love.math.colorFromBytes(66, 150, 250, 255)}
local d = {love.math.colorFromBytes(66, 150, 250, 102)}

local function get_color(active, hovered)
	if hovered then
		return active and a or h
	end
	return d
end

function ui.button(text)
	local id = just.get_id(text)
	local view = ui.views.button

	local changed, active, hovered = just.button_behavior(id, view:is_over())
	just.next(view:draw(text, active, hovered))

	return changed
end

function ui.checkbox(id, out)
	id = just.get_id(id)
	local view = ui.views.checkbox
	local k, t = next(out)

	local changed, active, hovered = just.button_behavior(id, view:is_over())
	if changed then
		t[k] = not t[k]
	end
	just.next(view:draw(active, hovered, t[k]))

	return changed
end

function ui.slider(id, out, min, max, vertical)
	id = just.get_id(id)
	local view = ui.views.slider
	local k, t = next(out)
	local value = t[k]
	local _value = (value - min) / (max - min)

	local pos = view:get_pos(vertical)
	local new_value, active, hovered = just.slider_behavior(id, view:is_over(), pos, _value)

	value = min + (max - min) * (new_value or _value)
	just.next(view:draw(active, hovered, value, min, max, vertical))
	t[k] = value

	return new_value
end

function ui.begin_window(id, w, h)
	id = just.get_id(id)

	local view = get_state(id, ui.views.window)
	view.height_start = just.height
	view:begin_draw(w, h)

	local over = view:is_over(w, h)

	view.scroll = view.scroll or 0
	local content = view.height
	if content and content > h then
		local scroll = just.wheel_behavior(id, over)
		if scroll then
			view.scroll = math.min(math.max(view.scroll + scroll * 50, h - content), 0)
		end
	end
	love.graphics.translate(0, view.scroll)

	if just.begin_container_behavior(id, over) then
		return just.mouse.dx, just.mouse.dy
	end
	return 0, 0
end

function ui.end_window()
	local id = just.end_container_behavior()
	local view = get_state(id, ui.views.window)
	view.height = just.height - view.height_start
	view:end_draw()
end

function ui.begin_dropdown(id, preview, w)
	id = just.get_id(id)

	local view = get_state(id, ui.views.window)

	if ui.button(preview) then
		view.is_open = not view.is_open
	end

	if not view.is_open then
		return
	end

	view.height_start = just.height
	local h = view.height or 0
	w = w or 100

	view:begin_draw(w, h)
	local over = view:is_over(w, h)
	just.begin_container_behavior(id, over)

	return true
end

ui.end_dropdown = ui.end_window

return ui
