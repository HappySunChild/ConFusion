local instances = require "../types"

local SpecialKey = require "../keys/SpecialKey"

return SpecialKey "Derives" {
	stage = "self",
	apply = function(_, applyTo: StyleSheet, derives: { StyleSheet })
		applyTo:SetDerives(derives)
	end,
} :: instances.SpecialKey<"Derives">
