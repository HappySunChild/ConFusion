local memory = require "../core-memory/types"

type function PropertiesOf(class: type)
	local BLACKLISTED_PROPERTIES = {
		"RobloxLocked",
		"GuiState",
		"AbsolutePosition",
		"AbsoluteRotation",
		"AbsoluteSize",
	}

	local output = {}

	local current = class

	-- max depth
	for _ = 1, 5 do
		if current == nil then
			break
		end

		for key, value in current:properties() do
			local v_write = value.write

			if
				v_write == nil
				or v_write:is "function"
				or v_write:is "table"
				or v_write:is "intersection"
			then
				continue
			end

			if table.find(BLACKLISTED_PROPERTIES, key:value()) then
				continue
			end

			output[key] = types.any
		end

		current = current:readparent()
	end

	return types.newtable(output)
end

export type New<Name, Class> = (
	scope: memory.Scope,
	class_name: Class
) -> (props: PropertiesOf<Class>) -> Class

return nil
