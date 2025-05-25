--!strict
local Types = require "../../Types"

local applyStyleProperties = require "./applyStyleProperties"

local function Rule(scope: Types.Scope, selector: string)
	local newRule = Instance.new "StyleRule"
	newRule.Name = selector
	newRule.Selector = selector

	return function(props: Types.StyleProperties)
		table.insert(scope, newRule)

		applyStyleProperties(newRule, props)

		return newRule
	end
end

return Rule
