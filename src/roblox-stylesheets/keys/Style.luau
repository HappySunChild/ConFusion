local calc = require "../../calc/types"
local instances = require "../../roblox-instances/types"
local memory = require "../../memory/types"

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
		link.Parent = applyTo

		applyProperties(scope, link, { StyleSheet = style })

		table.insert(scope, link)
	end,
} :: instances.SpecialKey<"Style">
