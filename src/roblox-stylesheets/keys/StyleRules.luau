local instances = require "../../roblox-instances/types"

local SpecialKey = require "../../roblox-instances/keys/SpecialKey"

return SpecialKey "StyleRules" {
	stage = "self",
	apply = function(_, apply_to: StyleBase, rules: { [number]: StyleRule })
		for priority, rule in rules do
			apply_to:InsertStyleRule(rule, priority)
		end
	end,
} :: instances.SpecialKey<"StyleRules">
