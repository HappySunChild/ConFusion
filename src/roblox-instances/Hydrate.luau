local instances = require "./types"
local memory = require "../core-memory/types"

local apply_properties = require "./apply_properties"

local function Hydrate<InstanceT>(
	scope: memory.Scope,
	instance: InstanceT
): (instances.Properties) -> InstanceT
	return function(properties: instances.Properties)
		table.insert(scope, instance)

		apply_properties(scope, instance, properties)

		return instance
	end
end

return Hydrate
