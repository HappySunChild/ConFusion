local instances = require "../types"

local SpecialKey = require "../keys/SpecialKey"

return SpecialKey "Default" {
	stage = "self",
	apply = function(_, applyTo: Instance, properties: { string })
		for _, property in properties do
			applyTo:ResetPropertyToDefault(property)
		end
	end,
} :: instances.SpecialKey<"Default">
