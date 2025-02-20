--!strict

local function nameOf(value: unknown, default: string)
	if typeof(value) == 'table' then
		if value.name ~= nil then
			return value.name
		elseif value.type ~= nil then
			return value.type
		elseif value.kind ~= nil then
			return value.kind
		end
	end

	return default
end

return nameOf
