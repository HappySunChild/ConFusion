local calc = require "../../core-calc/types"

local function Equals(target: calc.UsedAs<any>)
	return function(value: unknown, use: calc.Use)
		return value == use(target)
	end
end

return Equals
