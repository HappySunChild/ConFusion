local External = require "../../External"
local Types = require "../../Types"

local xtypeof = require "../../Utility/xtypeof"

local SpecialKey = require "./SpecialKey"

local Ref = SpecialKey "Ref" {
	stage = "self",
	apply = function(_, applyTo: Instance, ref: Types.Value<Instance>)
		if xtypeof(ref) ~= "Value" then
			return External.logError("expectedType", nil, "Value", typeof(ref))
		end

		ref:set(applyTo)

		return
	end,
}

return Ref
