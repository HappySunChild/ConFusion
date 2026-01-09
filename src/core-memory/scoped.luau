local memory = require "./types"

local ExternalDebug = require "../core-external/ExternalDebug"

local merge = require "./merge"

local function scoped<S, M>(base: memory.Scope<S>, methods: M?): memory.Scope<S & M>
	local metatable =
		table.freeze { __index = table.freeze(merge(true, table.clone(base), methods)) }
	local new_scope = setmetatable({}, metatable)

	ExternalDebug.track_scope(new_scope)

	return new_scope
end

return scoped :: memory.DeriveScope
