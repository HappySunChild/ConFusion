local calc = require "../../core-calc/types"
local instances = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"

local xtypeof = require "../../xtypeof"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function Out(property: string): instances.SpecialKey<"Out">
	local key = keyCache[property]

	if not key then
		key = SpecialKey "Out" {
			stage = "observer",
			apply = function(
				scope: memory.Scope,
				applyTo: Instance,
				value: calc.Value<any>
			)
				if xtypeof(value) ~= "Value" then
					External.logError(
						instances.expectedType,
						nil,
						"Value",
						xtypeof(value)
					)
				end

				local event = applyTo:GetPropertyChangedSignal(property)

				table.insert(
					scope,
					event:Connect(function()
						value:set(applyTo[property])
					end)
				)
			end,
		}

		keyCache[property] = key
	end

	return key
end

return Out
