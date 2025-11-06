local calc = require "./types"

local xtypeof = require "../xtypeof"

local function castToState(target: unknown): calc.StateObject<unknown>?
	if xtypeof(target) == "State" then
		return target
	end

	return nil
end

return castToState
