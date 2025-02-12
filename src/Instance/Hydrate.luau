local package = script.Parent.Parent

local Types = require(package.Types)
local applyProperties = require(script.Parent.applyProperties)

local function Hydrate(target: Instance, props: Types.Properties)
	applyProperties(target, props)

	return target
end

return Hydrate
