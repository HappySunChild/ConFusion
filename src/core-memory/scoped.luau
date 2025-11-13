local memory = require "./types"

local ExternalDebug = require "../core-external/ExternalDebug"

local merge = require "./merge"

local function scoped(
	base: memory.Scope<{ [unknown]: unknown }>,
	methods: { [unknown]: unknown }
): unknown
	local metatable = { __index = merge(false, {}, base, methods) }
	local scope = setmetatable({}, metatable)

	ExternalDebug.trackScope(scope)

	return scope
end

return scoped :: memory.DeriveScope
