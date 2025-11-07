local function NaN(value: unknown)
	return value ~= value
end

return NaN
