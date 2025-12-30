local memory = require "../core-memory/types"

local StyleProperties = require "./keys/StyleProperties"
local StyleRules = require "./keys/StyleRules"

local applyProperties = require "../roblox-instances/applyProperties"

local function StyleRule(scope: memory.Scope, selector: string)
	local new_rule = Instance.new "StyleRule"

	return function(props: { [string]: any }): (subrules: { StyleRule }) -> StyleRule
		return function(subrules: { StyleRule }): StyleRule
			table.insert(scope, new_rule)

			applyProperties(scope, new_rule, {
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
