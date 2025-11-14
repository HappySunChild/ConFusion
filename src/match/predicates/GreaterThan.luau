local calc = require "../../core-calc/types"

local function GreaterThan(minimum: calc.UsedAs<number>)
	return function(value: unknown, use: calc.Use)
		return type(value) == "number" and value > use(minimum)
	end
end

return GreaterThan
