local calc = require "../core-calc/types"

local cast_to_state = require "../core-calc/cast_to_state"

local evaluate = require "../core-graph/evaluate"

local function peek<T>(target: calc.UsedAs<T>): T
	if cast_to_state(target) ~= nil then
		evaluate(target)

		return target._internal_value :: T
	end

	return target :: T
end

return peek
