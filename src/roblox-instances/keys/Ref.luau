local calc = require "../../core-calc/types"
local instances = require "../types"

local External = require "../../core-external/External"
local SpecialKey = require "./SpecialKey"
local xtypeof = require "../../xtypeof"

local function applyRef(ref: unknown, instance: Instance)
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

	External.logError(instances.expectedType, nil, "Value", ref_type)
end

local Ref = SpecialKey "self" {
	name = "Ref",
	apply = function(
		_,
		apply_to: Instance,
		refs: { calc.Value<Instance> } | calc.Value<Instance>
	)
		applyRef(refs, apply_to)
	end,
}

return Ref
