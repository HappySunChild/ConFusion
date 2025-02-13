local package = script.Parent.Parent

local Types = require(package.Types)
local applyProperties = require(script.Parent.applyProperties)

local function Hydrate(scope: Types.Scope, target: Instance, props: Types.Properties)
	applyProperties(scope, target, props)
	
	return target
end

return Hydrate
