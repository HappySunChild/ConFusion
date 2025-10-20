local memory = require "./types"

local ExternalDebug = require "../external/ExternalDebug"

local merge = require "./merge"

local function deriveScope<S>(
	existing: memory.Scope<S>,
	methods: { [unknown]: unknown }?
): unknown
	local metatable = getmetatable(existing :: any)

	if methods ~= nil then
		metatable = table.clone(metatable) :: any
		metatable.__index = merge(true, {}, metatable.__index, merge(false, {}, methods))
	end

	local scope = setmetatable({}, metatable)

	ExternalDebug.trackScope(scope)

	return scope
end

return deriveScope :: <T, M>(existing: T, methods: M?) -> T & M
