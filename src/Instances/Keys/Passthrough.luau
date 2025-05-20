local package = script.Parent.Parent.Parent

local Types = require(package.Types)
local applyProperties = require(package.Instances.applyProperties)

local Passthrough = table.freeze {
	type = "Passthrough",
	kind = "key",
	stage = "properties",

	apply = applyProperties,
} :: Types.SpecialKey<"Passthrough">

return Passthrough
