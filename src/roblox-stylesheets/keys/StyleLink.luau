local calc = require "../../core-calc/types"
local memory = require "../../core-memory/types"

local apply_properties = require "../../roblox-instances/apply_properties"

local SpecialKey = require "../../roblox-instances/keys/SpecialKey"

return SpecialKey(
	"descendants",
	"StyleLink",
	function(scope: memory.Scope, apply_to: Instance, style: calc.UsedAs<StyleSheet>)
		local link = Instance.new "StyleLink"

		apply_properties(scope, link, {
			Parent = apply_to,
			StyleSheet = style,
		})

		table.insert(scope, link)
	end
)
