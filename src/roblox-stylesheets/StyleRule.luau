local memory = require "../core-memory/types"
local style = require "./types"

local RuleProperties = require "./keys/RuleProperties"
local Rules = require "./keys/Rules"

local applyProperties = require "../roblox-instances/applyProperties"

local function StyleRule(scope: memory.Scope, selector: string)
	local new_rule = Instance.new "StyleRule"

	return function(props: style.StyleRuleProperties): StyleRule
		table.insert(scope, new_rule)

		local rule_properties = {}

		for property, value in props do
			-- this feels awful, but the other alternative was a "properties" table within the properties table, which already sounds weird
			-- and was pretty awkward since it caused a lot of indenting
			if property == "rules" then
				continue
			end

			rule_properties[property] = value
		end

		applyProperties(scope, new_rule, {
			Selector = selector,
			Name = selector,

			[Rules] = props.rules,
			[RuleProperties] = rule_properties,
		})

		return new_rule
	end
end

return StyleRule
