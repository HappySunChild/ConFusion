local instances = require "./types"
local memory = require "../memory/types"

local applyProperties = require "./applyProperties"

local function Hydrate(
	scope: memory.Scope,
	instance: Instance
): (props: instances.Properties) -> Instance
	return function(props: instances.Properties)
		table.insert(scope, instance)

		applyProperties(scope, instance, props)

		return instance
	end
end

return Hydrate
