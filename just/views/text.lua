local TextView = {}

function TextView:draw(text, limit)
	love.graphics.setColor(1, 1, 1, 1)
	local font = love.graphics.getFont()
	love.graphics.printf(text, 0, 0, limit, "left")
	local width, wrappedText = font:getWrap(text, limit)
	return width, font:getHeight() * #wrappedText
end

return TextView
