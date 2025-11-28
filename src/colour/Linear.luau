local function to_linear(channel: number): number
	if channel < 0.04045 then
		return channel / 12.92
	end

	return ((channel + 0.055) / 1.055) ^ 2.4
end

local function to_SRGB(channel: number): number
	if channel <= 0.0031308 then
		return channel * 12.92
	end

	return (1.055 * channel ^ (1 / 2.4)) - 0.055
end

return table.freeze {
	fromLinearToSRGB = function(rgb: vector): vector
		return vector.create(to_SRGB(rgb.x), to_SRGB(rgb.y), to_SRGB(rgb.z))
	end,
	fromSRGBToLinear = function(srgb: vector): vector
		return vector.create(to_linear(srgb.x), to_linear(srgb.y), to_linear(srgb.z))
	end,
}
