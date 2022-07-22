

return function(offset, size, _w)
	local w = {}
	local x = {}

	local piexls = 0
	for i = 1, #_w do
		local v = _w[i]
		if v ~= "*" and v > 0 then
			piexls = piexls + _w[i]
		end
	end

	local pos = offset
	local fill = false
	for i = 1, #_w do
		local v = _w[i]
		w[i] = v
		if v == "*" then
			w[i] = 0
			assert(not fill)
			fill = true
		elseif v < 0 then
			w[i] = -v * (size - piexls)
		end
		pos = pos + w[i]
	end

	local rest = size - pos
	pos = offset

	for i = 1, #_w do
		if w[i] == 0 then
			w[i] = rest
		end
		x[i] = pos
		pos = pos + w[i]
	end

	return x, w
end
