local instances = require "./types"
local memory = require "../core-memory/types"

local applyProperties = require "./applyProperties"

local function Hydrate<InstanceT>(
	scope: memory.Scope,
	instance: InstanceT
): (properties: instances.Properties) -> InstanceT
	return function(properties: instances.Properties)
		table.insert(scope, instance)

		applyProperties(scope, instance, properties)

		return instance
	end
end

return Hydrate
