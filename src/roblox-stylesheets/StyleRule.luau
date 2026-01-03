local memory = require "../core-memory/types"

local StyleProperties = require "./keys/StyleProperties"
local StyleRules = require "./keys/StyleRules"

local apply_properties = require "../roblox-instances/apply_properties"

local function StyleRule(scope: memory.Scope, selector: string)
	local new_rule = Instance.new "StyleRule"

	return function(props: { [string]: any }): (subrules: { StyleRule }) -> StyleRule
		return function(subrules: { StyleRule }): StyleRule
			table.insert(scope, new_rule)

			apply_properties(scope, new_rule, {
				Selector = selector,
				Name = selector,

				[StyleRules] = subrules,
				[StyleProperties] = props,
			})

			return new_rule
		end
	end
end

return StyleRule
