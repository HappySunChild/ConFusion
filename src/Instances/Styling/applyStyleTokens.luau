local Types = require "../../Types"

local castToState = require "../../State/castToState"
local peek = require "../../State/peek"

local Observer = require "../../Graph/Observer"

local function setStyleToken(sheet: StyleSheet, name: string, value: any)
	sheet:SetAttribute(name, value)
end

local function applyStyleToken(
	scope: Types.Scope,
	sheet: StyleSheet,
	name: string,
	value: Types.UsedAs<any>
)
	if castToState(value) then
		Observer(scope, value):onBind(function()
			setStyleToken(sheet, name, peek(value))
		end)

		return
	end

	setStyleToken(sheet, name, value)
end

local function applyStyleTokens(
	scope: Types.Scope,
	sheet: StyleSheet,
	tokens: { [string]: any }
)
	for name, value in tokens do
		applyStyleToken(scope, sheet, name, value)
	end
end

return applyStyleTokens
