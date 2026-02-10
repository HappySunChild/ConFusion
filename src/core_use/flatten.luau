local calc = require("../core_calc/types")

local cast_to_state = require("../core_calc/cast_to_state")

local function flatten<T>(use: calc.Use, x: calc.UsedAs<T>): T
	while cast_to_state(x) ~= nil do
		x = use(x)
	end

	return x
end

return flatten
