local Types = require "../../Types"

local castToState = require "../../State/castToState"
local peek = require "../../State/peek"

local observe = require "../../Graph/observe"

local function setStyleProperty(rule: StyleRule, property: string, value: any)
	rule:SetProperty(property, value)
end

local function applyStyleProperty(
	rule: StyleRule,
	property: string,
	value: Types.UsedAs<any>
)
	if castToState(value) then
		observe(value, function()
			setStyleProperty(rule, property, peek(value))
		end, true)

		return
	end

	setStyleProperty(rule, property, value)
end

local function applyStyleProperties(rule: StyleRule, props: Types.StyleProperties)
	props = table.clone(props)

	for key, value in props do
		if key ~= "Rules" then
			applyStyleProperty(rule, key, value)
		end
	end

	local rules = props.Rules

	if rules then
		for priority, subRule in rules do
			rule:InsertStyleRule(subRule, priority)
		end
	end
end

return applyStyleProperties
