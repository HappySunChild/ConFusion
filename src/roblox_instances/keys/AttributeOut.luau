local calc = require("../../core_calc/types")
local instances = require("../types")
local memory = require("../../core_memory/types")

local External = require("../../core_external/External")
local SpecialKey = require("../SpecialKey")
local xtypeof = require("../../core_graph/xtypeof")

local KEY_CACHE = {}

local function AttributeOut(attribute: string): instances.SpecialKey<"AttributeOut">
	local key = KEY_CACHE[attribute]

	if key == nil then
		key = SpecialKey(
			"observer",
			"AttributeOut",
			function(scope: memory.Scope, apply_to: Instance, value: calc.Value<any>)
				if xtypeof(value) ~= "State" or value.Kind ~= "Value" then
					External.log_error(instances.invalid_out_type, nil, typeof(value))
				end

				local event = apply_to:GetAttributeChangedSignal(attribute)

				table.insert(
					scope,
					event:Connect(function()
						value:set(apply_to:GetAttribute(attribute))
					end)
				)

				return
			end
		)

		KEY_CACHE[attribute] = key
	end

	return key
end

return AttributeOut
