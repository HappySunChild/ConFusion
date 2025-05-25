local Types = require "../../Types"

local castToState = require "../../State/castToState"
local peek = require "../../State/peek"

local observe = require "../../Graph/observe"

local function setStyleToken(sheet: StyleSheet, name: string, value: any)
	sheet:SetAttribute(name, value)
end

local function applyStyleToken(sheet: StyleSheet, name: string, value: Types.UsedAs<any>)
	if castToState(value) then
		observe(value, function()
			setStyleToken(sheet, name, peek(value))
		end, true)

		return
	end

	setStyleToken(sheet, name, value)
end

local function applyStyleTokens(sheet: StyleSheet, tokens: { [string]: any })
	for name, value in tokens do
		applyStyleToken(sheet, name, value)
	end
end

return applyStyleTokens
