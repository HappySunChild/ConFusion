local memory = require "./types"

local ExternalDebug = require "../core-external/ExternalDebug"

local merge = require "./merge"

local function derive_scope<S, M>(existing: memory.Scope<S>, methods: M?): memory.Scope<S & M>
	local metatable = getmetatable(existing)

	local derived_metatable = if methods == nil
		then metatable -- reuse old metatable because nothing is being changed. surely this won't have dire consequence, right?
		else table.freeze {
			-- only deriving the __index metamethod, as any other metamethod is basically irrelevant and probably shouldn't be applied on a scope anyway (besides maybe __tostring)
			__index = table.freeze(
				merge(
					true,
					if metatable ~= nil and type(metatable.__index) == "table"
						then table.clone(metatable.__index)
						else {},
					methods
				)
			),
		}

	local derived_scope = setmetatable({}, derived_metatable)

	ExternalDebug.track_scope(derived_scope)

	return derived_scope
end

return derive_scope :: memory.DeriveScope
