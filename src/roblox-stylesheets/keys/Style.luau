local calc = require "../../core-calc/types"
local instances = require "../../roblox-instances/types"
local memory = require "../../core-memory/types"

local applyProperties = require "../../roblox-instances/applyProperties"

local SpecialKey = require "../../roblox-instances/keys/SpecialKey"

return SpecialKey "Style" {
	stage = "descendants",
	apply = function(
		scope: memory.Scope,
		applyTo: Instance,
		style: calc.UsedAs<StyleSheet>
	)
		local link = Instance.new "StyleLink"

		applyProperties(scope, link, {
			Parent = applyTo,
			StyleSheet = style,
		})

		table.insert(scope, link)
	end,
} :: instances.SpecialKey<"Style">
