local calc = require "../../calc/types"

local External = require "../../External"
local xtypeof = require "../../xtypeof"

local SpecialKey = require "./SpecialKey"

local Ref = SpecialKey "Ref" {
	stage = "self",
	apply = function(_, applyTo: Instance, ref: calc.Value<Instance>)
		if xtypeof(ref) ~= "Value" then
			External.logError("expectedType", nil, "Value", xtypeof(ref))
		end

		ref:set(applyTo)

		return
	end,
}

return Ref
