local calc = require "../core-calc/types"

local castToState = require "../core-calc/castToState"

local evaluate = require "../core-graph/evaluate"

local function peek<T>(target: calc.UsedAs<T>): T
	if castToState(target) ~= nil then
		evaluate(target)

		return target._internalValue :: T
	end

	return target :: T
end

return peek
