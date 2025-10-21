local calc = require "../core-calc/types"

local castToState = require "../core-calc/castToState"

local evaluate = require "../core-graph/evaluate"

local function peek<V>(target: calc.StateObject<V> | V): V
	if castToState(target) then
		evaluate(target)

		return target._internalValue :: V
	end

	return target :: V
end

return peek
