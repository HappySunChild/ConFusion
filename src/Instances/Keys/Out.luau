local External = require "../../External"
local Types = require "../../Types"

local xtypeof = require "../../Utility/xtypeof"

local SpecialKey = require "./SpecialKey"

local keyCache = {}

local function Out(property: string): Types.SpecialKey<"Out">
	local key = keyCache[property]

	if not key then
		key = SpecialKey "Out" {
			stage = "observer",
			apply = function(
				scope: Types.Scope,
				applyTo: Instance,
				value: Types.Value<unknown>
			)
				if xtypeof(value) ~= "Value" then
					External.logError("expectedType", nil, "Value", typeof(value))
				end

				local ok, event =
					pcall(applyTo.GetPropertyChangedSignal, applyTo, property)

				if not ok then
					External.logError("cannotConnectChange", nil, property)
				end

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
