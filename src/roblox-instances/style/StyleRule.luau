local memory = require "../../memory/types"
local style = require "./types"

local RuleProperties = require "./RuleProperties"
local Rules = require "./Rules"

local applyProperties = require "../applyProperties"

local function StyleRule(scope: memory.Scope, selector: string)
	local newRule = Instance.new "StyleRule"
	newRule.Name = selector
	newRule.Selector = selector

	return function(props: style.StyleRuleProperties): StyleRule
		table.insert(scope, newRule)

		local ruleProperties = {}

		for property, value in props do
			-- this feels awful, but the other alternative was a "properties" table within the properties table, which already sounds weird
			-- and was pretty awkward since it caused a lot of indenting
			if property == "rules" then
				continue
			end

			ruleProperties[property] = value
		end

		applyProperties(scope, newRule, {
			[Rules] = props.rules,
			[RuleProperties] = ruleProperties,
		})

		return newRule
	end
end

return StyleRule
