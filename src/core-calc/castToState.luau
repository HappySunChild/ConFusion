local calc = require "./types"

local kindof = require "../kindof"

local function castToState(target: unknown): calc.StateObject<unknown>?
	if kindof(target) == "state" then
		return target
	end

	return nil
end

return castToState
