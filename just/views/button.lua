local just_print = require("just.print")
local just_color = require("just.color")

local ButtonView = {
	w = 80, h = 40,
}

function ButtonView:is_over()
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= x and x <= self.w and 0 <= y and y <= self.h
end

function ButtonView:draw(text, active, hovered)
	local w, h = self.w, self.h
	love.graphics.setColor(just_color(active, hovered))
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h)
	just_print(text, 0, 0, w, h, "center", "center")
	return w, h
end

return ButtonView
