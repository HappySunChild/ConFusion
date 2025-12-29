local memory = require "./types"

local ExternalDebug = require "../core-external/ExternalDebug"

local merge = require "./merge"

local function derive_scope<S>(
	existing: memory.Scope<S>,
	methods: { [unknown]: unknown }?
): unknown
	local metatable = getmetatable(existing :: any)

	if methods ~= nil then
		metatable = table.clone(metatable) :: any
		metatable.__index = merge(true, {}, metatable.__index, merge(false, {}, methods))
	end

	local scope = setmetatable({}, metatable)

	ExternalDebug.track_scope(scope)

	return scope
end

return derive_scope :: memory.DeriveScope
