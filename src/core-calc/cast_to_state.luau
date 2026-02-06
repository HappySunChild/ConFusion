local calc = require("./types")

local xtypeof = require("../core-graph/xtypeof")

local function cast_to_state(x: unknown): calc.StateNode<unknown>?
	if xtypeof(x) == "State" then
		return x
	end

	return nil
end

return cast_to_state
