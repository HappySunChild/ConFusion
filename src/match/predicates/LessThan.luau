local calc = require "../../core-calc/types"

local function LessThan(maximum: calc.UsedAs<number>)
	return function(value: unknown, use: calc.Use)
		return type(value) == "number" and value < use(maximum)
	end
end

return LessThan
