local calc = require "../../core-calc/types"
local instances = require "../types"

local External = require "../../core-external/External"

local xtypeof = require "../../xtypeof"

local SpecialKey = require "./SpecialKey"

local Ref = SpecialKey "self" {
	name = "Ref",
	apply = function(
		_,
		apply_to: Instance,
		refs: { calc.Value<Instance> } | calc.Value<Instance>
	)
		if xtypeof(refs) == "Value" then
			refs = refs :: calc.Value<Instance>
			refs:set(apply_to)

			return
		end

		refs = refs :: { calc.Value<Instance> }
		for _, ref in refs do
			if xtypeof(ref) ~= "Value" then
				External.logError(instances.expectedType, nil, "Value", xtypeof(ref))
			end

			ref:set(apply_to)
		end
	end,
}

return Ref
