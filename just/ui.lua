local just = require("just")
local just_print = require("just.print")

local ui = {}

local next_id

function ui.set_id(id)
	next_id = id
end

function ui.get_id(id)
	id = next_id or id
	next_id = nil
	return id
end

local colors = {
	a = {love.math.colorFromBytes(15, 135, 250, 255)},
	h = {love.math.colorFromBytes(66, 150, 250, 255)},
	d = {love.math.colorFromBytes(66, 150, 250, 102)},
}

local function get_color(active, hovered)
	if hovered then
		return active and colors.a or colors.h
	end
	return colors.d
end

function ui.button(text)
	local id = ui.get_id(text)

	local w, h = 80, 40
	local changed, active, hovered = just.button(id, just.is_over(w, h))

	love.graphics.setColor(get_color(active, hovered))
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h)
	just_print(text, 0, 0, w, h, "center", "center")

	just.next(w, h)

	return changed
end

function ui.checkbox(id, out)
	id = ui.get_id(id)
	local k, t = next(out)

	local size = 40

	local changed, active, hovered = just.button(id, just.is_over(size, size))
	if changed then
		t[k] = not t[k]
	end

	love.graphics.setColor(get_color(active, hovered))
	love.graphics.rectangle("fill", 0, 0, size, size)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, size, size)

	if t[k] then
		love.graphics.line(size / 6, size / 2, (1 / 6 + 2 / 9) * size, 4.5 / 6 * size)
		love.graphics.line((1 / 6 + 2 / 9) * size, 4.5 / 6 * size, 5 / 6 * size, 1.5 / 6 * size)
	end

	just.next(size, size)

	return changed
end

local function get_pos(w, h, vertical)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local a, b = x, w
	if vertical then
		a, b = y, h
	end
	return math.min(math.max(a / b, 0), 1)
end

function ui.slider(id, out, min, max, vertical)
	id = ui.get_id(id)
	local k, t = next(out)
	local value = t[k]
	local _value = (value - min) / (max - min)

	local w, h = 80, 40

	local pos = get_pos(w, h, vertical)
	local new_value, active, hovered = just.slider(id, just.is_over(w, h), pos, _value)

	love.graphics.setColor(get_color(active, hovered))
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(1, 1, 1, 0.3)
	if vertical then
		love.graphics.rectangle("fill", 0, 0, w, h * (value - min) / (max - min))
	else
		love.graphics.rectangle("fill", 0, 0, w * (value - min) / (max - min), h)
	end
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h)
	just_print(("%0.3f"):format(math.floor(value * 1000) / 1000), 0, 0, w, h, "center", "center")

	t[k] = min + (max - min) * (new_value or _value)
	just.next(w, h)

	return new_value
end

local sw, sh
local function drawStencil()
	love.graphics.rectangle("fill", 0, 0, sw, sh)
end

local window_scrolls = {}
local window_heights = {}
local window_height_starts = {}
local window_w = {}
local window_h = {}
function ui.begin_window(id, w, h)
	id = ui.get_id(id)

	window_height_starts[id] = just.height

	love.graphics.setColor(love.math.colorFromBytes(15, 15, 15, 240))
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(love.math.colorFromBytes(69, 69, 69, 255))
	love.graphics.push()

	window_w[id] = w
	window_h[id] = h

	sw, sh = w, h
	love.graphics.stencil(drawStencil, "replace", 1, false)
	love.graphics.setStencilTest("greater", 0)

	local over = just.is_over(w, h)

	window_scrolls[id] = window_scrolls[id] or 0
	local content = window_heights[id]
	if content and content > h then
		local scroll = just.wheel_over(id, over)
		if scroll then
			window_scrolls[id] = math.min(math.max(window_scrolls[id] + scroll * 50, h - content), 0)
		end
	end
	love.graphics.translate(0, window_scrolls[id])

	if just.container(id, over) then
		return just.mouse.dx, just.mouse.dy
	end
	return 0, 0
end

function ui.end_window()
	local id = just.container()
	window_heights[id] = just.height - window_height_starts[id]
	love.graphics.setStencilTest()
	love.graphics.pop()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 0, 0, window_w[id], window_h[id])
end

local dropdown_open = {}
function ui.begin_dropdown(id, preview, w)
	id = ui.get_id(id)

	if ui.button(preview) then
		dropdown_open[id] = not dropdown_open[id]
	end

	if not dropdown_open[id] then
		return
	end

	window_height_starts[id] = just.height
	local h = window_heights[id] or 0
	w = w or 100

	love.graphics.setColor(love.math.colorFromBytes(15, 15, 15, 240))
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(love.math.colorFromBytes(69, 69, 69, 255))
	love.graphics.push()

	window_w[id] = w
	window_h[id] = h

	sw, sh = w, h
	love.graphics.stencil(drawStencil, "replace", 1, false)
	love.graphics.setStencilTest("greater", 0)

	local over = just.is_over(w, h)
	just.container(id, over)

	return true
end

ui.end_dropdown = ui.end_window

return ui
