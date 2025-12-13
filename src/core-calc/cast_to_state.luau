local calc = require "./types"

local xtypeof = require "../core-graph/xtypeof"

local function cast_to_state(target: unknown): calc.StateObject<unknown>?
	if xtypeof(target) == "State" then
		return target
	end

	return nil
end

return cast_to_state
