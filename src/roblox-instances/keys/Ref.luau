local calc = require "../../core-calc/types"
local instances = require "../types"

local External = require "../../core-external/External"
local SpecialKey = require "./SpecialKey"
local xtypeof = require "../../xtypeof"

local function applyRef(
	instance: Instance,
	ref: { calc.Value<Instance> } | calc.Value<Instance>
)
	local ref_type = xtypeof(ref)

	if ref_type == "Value" then
		ref = ref :: calc.Value<Instance>
		ref:set(instance)

		return
	elseif ref_type == "table" then
		for _, sub_ref in ref do
			applyRef(sub_ref, instance)
		end

		return
	end

	External.logError(instances.expected_type, nil, "Value", ref_type)
end

local Ref = SpecialKey("self", "Ref", function(scope, apply_to: Instance, ref: unknown)
	applyRef(apply_to, ref)
end)

return Ref
