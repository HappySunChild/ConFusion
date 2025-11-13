local calc = require "../core-calc/types"
local graph = require "../core-graph/types"

local castToState = require "../core-calc/castToState"

local depend = require "../core-graph/depend"

local peek = require "./peek"

local function genericUse(user: graph.GraphObject): calc.Use
	local function use<T>(target: calc.UsedAs<T>): T
		depend(user, castToState(target))

		return peek(target)
	end

	return use
end

return genericUse
