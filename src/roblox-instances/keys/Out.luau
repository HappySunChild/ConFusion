local calc = require "../../core-calc/types"
local instances = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"

local xtypeof = require "../../core-graph/xtypeof"

local SpecialKey = require "./SpecialKey"

local KEY_CACHE = {}

local function Out(property: string): instances.SpecialKey<"Out">
	local key = KEY_CACHE[property]

	if key == nil then
		key = SpecialKey(
			"observer",
			"Out",
			function(scope: memory.Scope, apply_to: Instance, value: calc.Value<any>)
				if xtypeof(value) ~= "State" or value.kind ~= "Value" then
					External.log_error(
						instances.expected_type,
						nil,
						"Value",
						xtypeof(value)
					)
				end

				local event = apply_to:GetPropertyChangedSignal(property)

				table.insert(
					scope,
					event:Connect(function()
						value:set(apply_to[property])
					end)
				)
			end
		)

		KEY_CACHE[property] = key
	end

	return key
end

return Out
