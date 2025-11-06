local applyProperties = require "../applyProperties"

local SpecialKey = require "./SpecialKey"

local Passthrough = SpecialKey("properties", "Passthrough", applyProperties)

return Passthrough
