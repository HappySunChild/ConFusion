local memory = require("./types")

local ExternalDebug = require("../core_external/ExternalDebug")

local merge = require("./merge")

local function scoped<S, M>(base: S, methods: M?): memory.Scope<S & M>
	local new_scope = setmetatable(
		{},
		{ __index = if methods == nil then base else merge(true, table.clone(base), methods) }
	)

	ExternalDebug.track_scope(new_scope)

	return new_scope
end

return scoped
