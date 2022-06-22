local a = {love.math.colorFromBytes(15, 135, 250, 255)}
local h = {love.math.colorFromBytes(66, 150, 250, 255)}
local d = {love.math.colorFromBytes(66, 150, 250, 102)}

return function(active, hovered)
	if hovered then
		return active and a or h
	end
	return d
end
