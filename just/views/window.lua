local WindowView = {}

function WindowView:is_over(w, h)
	local x, y = love.graphics.inverseTransformPoint(love.mouse.getPosition())
	return 0 <= x and x <= w and 0 <= y and y <= h
end

local sw, sh
local function drawStencil()
	love.graphics.rectangle("fill", 0, 0, sw, sh)
end

function WindowView:begin_draw(w, h)
	self.w, self.h = w, h
	love.graphics.setColor(love.math.colorFromBytes(15, 15, 15, 240))
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setColor(love.math.colorFromBytes(69, 69, 69, 255))
	love.graphics.push()

	sw, sh = w, h
	love.graphics.stencil(drawStencil, "replace", 1, false)
	love.graphics.setStencilTest("greater", 0)

	return w, h
end

function WindowView:end_draw()
	love.graphics.setStencilTest()
	love.graphics.pop()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("line", 0, 0, self.w, self.h)
end

return WindowView
