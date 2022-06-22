local just_print = require("just.print")
local just_color = require("just.color")

local SliderView = {
	w = 120, h = 40,
}

function SliderView:is_over()
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= x and x <= self.w and 0 <= y and y <= self.h
end

function SliderView:get_pos(vertical)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	local a, b = x, self.w
	if vertical then
		a, b = y, self.h
	end
	return math.min(math.max(a / b, 0), 1)
end

function SliderView:draw(active, hovered, value, min, max, vertical)
	local w, h = self.w, self.h
	love.graphics.setColor(just_color(active, hovered))
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

	return w, h
end

return SliderView
