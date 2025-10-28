local applyProperties = require "../applyProperties"

local SpecialKey = require "./SpecialKey"

local Passthrough = SpecialKey "properties" {
	name = "Passthrough",
	apply = applyProperties, -- TODO: not this
}

return Passthrough
