local calc = require "../../core-calc/types"

local function OfType(target_type: calc.UsedAs<string>)
	return function(value: unknown, use: calc.Use)
		return typeof(value) == use(target_type)
	end
end

return OfType
