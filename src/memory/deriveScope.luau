local memory = require "./types"

local merge = require "./merge"

local function deriveScope<S>(
	existing: memory.Scope<S>,
	methods: { [unknown]: unknown }?
): unknown
	local metatable = getmetatable(existing :: any)

	if methods ~= nil then
		metatable = table.clone(metatable) :: { [unknown]: unknown }
		metatable.__index = merge(true, {}, metatable.__index, merge(false, {}, methods))
	end

	return setmetatable({}, metatable)
end

return deriveScope :: <T, M>(existing: T, methods: M?) -> T & M
