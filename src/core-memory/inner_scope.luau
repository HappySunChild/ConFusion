local memory = require "./types"

local derive_scope = require "./derive_scope"

local function inner_scope<T>(
	existing: memory.Scope<T>,
	methods: { [unknown]: unknown }
): unknown
	local inner = derive_scope(existing, methods)

	table.insert(existing, inner)
	table.insert(inner, function()
		local index = table.find(existing, inner)

		if index ~= nil then
			table.remove(existing, index)
		end
	end)

	return inner
end

return inner_scope :: memory.derive_scope
