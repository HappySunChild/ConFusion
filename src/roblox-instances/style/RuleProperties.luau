local calc = require "../../calc/types"
local instances = require "../types"
local memory = require "../../memory/types"

local castToState = require "../../calc/castToState"

local peek = require "../../use/peek"

local observe = require "../../graph/observe"

local SpecialKey = require "../keys/SpecialKey"

local function applyProperty(
	scope: memory.Scope,
	rule: StyleRule,
	property: string,
	value: any
)
	if castToState(value) then
		observe(scope, value, function()
			rule:SetProperty(property, peek(value))
		end)
	end

	rule:SetProperty(property, peek(value))
end

return SpecialKey "RuleProperties" {
	stage = "self",
	apply = function(
		scope: memory.Scope,
		applyTo: StyleRule,
		properties: { [string]: calc.UsedAs<any> }
	)
		for property, value in properties do
			applyProperty(scope, applyTo, property, value)
		end
	end,
} :: instances.SpecialKey<"RuleProperties">
