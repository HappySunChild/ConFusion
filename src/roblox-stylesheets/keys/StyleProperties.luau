local calc = require "../../core-calc/types"
local instances = require "../../roblox-instances/types"
local memory = require "../../core-memory/types"

local castToState = require "../../core-calc/castToState"

local peek = require "../../core-use/peek"

local observe = require "../../core-graph/observe"

local SpecialKey = require "../../roblox-instances/keys/SpecialKey"

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

return SpecialKey "StyleProperties" {
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
} :: instances.SpecialKey<"StyleProperties">
