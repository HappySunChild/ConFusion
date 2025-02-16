local function typeOf(value: any): string
	local vType = typeof(value)

	if vType == 'table' then
		if value.type then
			return value.type
		end
	end

	return vType
end

return typeOf
