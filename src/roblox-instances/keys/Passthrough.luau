local apply_properties = require "../apply_properties"

local SpecialKey = require "./SpecialKey"

local Passthrough = SpecialKey("properties", "Passthrough", apply_properties)

return Passthrough
