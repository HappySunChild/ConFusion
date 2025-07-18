local Types = require "../../Types"

local castToState = require "../../State/castToState"
local peek = require "../../State/peek"

local Observer = require "../../Graph/Observer"

local function setStyleProperty(rule: StyleRule, property: string, value: any)
	rule:SetProperty(property, value)
end

local function applyStyleProperty(
	scope: Types.Scope,
	rule: StyleRule,
	property: string,
	value: Types.UsedAs<any>
)
	if castToState(value) then
		Observer(scope, value):onBind(function()
			setStyleProperty(rule, property, peek(value))
		end)

		return
	end

	setStyleProperty(rule, property, value)
end

local function applyStyleProperties(
	scope: Types.Scope,
	rule: StyleRule,
	props: Types.StyleProperties
)
	props = table.clone(props)

	for key, value in props do
		if key ~= "Rules" then
			applyStyleProperty(scope, rule, key, value)
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
