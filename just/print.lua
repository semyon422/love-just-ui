return function(text, x, y, w, h, ax, ay)
	local font = love.graphics.getFont()
	local _, wrappedText = font:getWrap(text, w)
	local height = font:getHeight() * font:getLineHeight() * #wrappedText

	if ay == "center" then
		y = y + (h - height) / 2
	elseif ay == "bottom" then
		y = y + h - height
	end

	love.graphics.printf(text, x, y, w, ax, 0)
end
