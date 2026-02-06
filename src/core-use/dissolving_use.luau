local calc = require("../core-calc/types")

local cast_to_state = require("../core-calc/cast_to_state")

local function dissolving_use<T>(x: calc.UsedAs<T>): T
	if cast_to_state(x) ~= nil then
		error("not-dissolvable")
	end

	return x
end

return dissolving_use
