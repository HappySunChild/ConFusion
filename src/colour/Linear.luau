local function toLinear(channel: number): number
	if channel < 0.04045 then
		return channel / 12.92
	end

	return ((channel + 0.055) / 1.055) ^ 2.4
end

local function toSRGB(channel: number): number
	if channel <= 0.0031308 then
		return channel * 12.92
	end

	return (1.055 * channel ^ (1 / 2.4)) - 0.055
end

return table.freeze {
	fromLinearToSRGB = function(rgb: vector): vector
		return vector.create(toSRGB(rgb.x), toSRGB(rgb.y), toSRGB(rgb.z))
	end,
	fromSRGBToLinear = function(srgb: vector): vector
		return vector.create(toLinear(srgb.x), toLinear(srgb.y), toLinear(srgb.z))
	end,
}
