local instances = require "../../roblox-instances/types"

local SpecialKey = require "../../roblox-instances/keys/SpecialKey"

return SpecialKey "StyleDerives" {
	stage = "self",
	apply = function(_, applyTo: StyleSheet, derives: { StyleSheet })
		applyTo:SetDerives(derives)
	end,
} :: instances.SpecialKey<"StyleDerives">
