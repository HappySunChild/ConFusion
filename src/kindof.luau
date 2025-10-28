local function kindof(value: any): string?
	local value_type = typeof(value)

	if value_type == "table" then
		return value.kind
	end

	return nil
end

return kindof
