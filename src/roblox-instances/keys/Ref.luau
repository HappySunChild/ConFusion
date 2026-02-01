local calc = require("../../core-calc/types")
local instances = require("../types")

local External = require("../../core-external/External")
local SpecialKey = require("../SpecialKey")
local xtypeof = require("../../core-graph/xtypeof")

type OneOrMore<T> = T | { T }

local function apply_ref(instance: Instance, ref: OneOrMore<calc.Value<Instance>>)
	local ref_type = xtypeof(ref)

	if ref_type == "State" and ref.kind == "Value" then
		ref = ref :: calc.Value<Instance>
		ref:set(instance)

		return
	elseif ref_type == "table" then
		for _, sub_ref in ref do
			apply_ref(sub_ref, instance)
		end

		return
	end

	External.log_error(instances.expected_type, nil, "Value", ref_type)
end

local Ref = SpecialKey(
	"self",
	"Ref",
	function(scope, apply_to: Instance, ref: OneOrMore<calc.Value<Instance>>)
		apply_ref(apply_to, ref)
	end
)

return Ref
