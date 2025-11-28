local calc = require "../core-calc/types"

local cast_to_state = require "../core-calc/cast_to_state"

local function flatten<T>(use: calc.Use, target: calc.UsedAs<T>): T
	while cast_to_state(target) ~= nil do
		target = use(target)
	end

	return target
end

return flatten
