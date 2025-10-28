local function kindof(value: any): string?
	local value_type = typeof(value)

	if value_type == "table" then
		if value.kind then
			return value.kind
		end
	end

	return nil
end

return kindof
