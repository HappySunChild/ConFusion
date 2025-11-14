local instances = require "../../roblox-instances/types"

local SpecialKey = require "../../roblox-instances/keys/SpecialKey"

return SpecialKey "Rules" {
	stage = "self",
	apply = function(_, applyTo: StyleBase, rules: { [number]: StyleRule })
		for priority, rule in rules do
			applyTo:InsertStyleRule(rule, priority)
		end
	end,
} :: instances.SpecialKey<"Rules">
