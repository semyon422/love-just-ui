local just_color = require("just.color")

local CheckboxView = {
	w = 40, h = 40,
}

function CheckboxView:is_over()
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= x and x <= self.w and 0 <= y and y <= self.h
end

function CheckboxView:draw(active, hovered, checked)
	local w, h = self.w, self.h
	love.graphics.setColor(just_color(active, hovered))
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0, 0, w, h)

	if checked then
		love.graphics.line(w / 6, h / 2, (1 / 6 + 2 / 9) * w, 4.5 / 6 * h)
		love.graphics.line((1 / 6 + 2 / 9) * w, 4.5 / 6 * h, 5 / 6 * w, 1.5 / 6 * h)
	end

	return w, h
end

return CheckboxView
