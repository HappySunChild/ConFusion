local calc = require "../../core-calc/types"

local function InRange(minimum: calc.UsedAs<number>, maximum: calc.UsedAs<number>)
	return function(value: unknown, use: calc.Use)
		if type(value) ~= "number" then
			return false
		end

		return value >= minimum and value <= maximum
	end
end

return InRange
