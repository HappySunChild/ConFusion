local calc = require "../core-calc/types"
local graph = require "../core-graph/types"

local cast_to_state = require "../core-calc/cast_to_state"

local depend = require "../core-graph/depend"

local peek = require "./peek"

local function generic_use(user: graph.GraphObject): calc.Use
	local function use<T>(target: calc.UsedAs<T>): T
		depend(user, cast_to_state(target))

		return peek(target)
	end

	return use
end

return generic_use
