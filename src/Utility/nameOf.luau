local package = script.Parent.Parent

local function nameOf(value: unknown, default: string)
	if typeof(value) == 'table' then
		if value.name then
			return value.name
		elseif value.type then
			return value.type
		elseif value.kind then
			return value.kind
		end
	end

	return default
end

return nameOf
