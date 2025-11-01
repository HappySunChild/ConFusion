local calc = require "../core-calc/types"
local iter = require "./types"
local memory = require "../core-memory/types"

local ForValues = require "./ForValues" -- either ForValues or ForKeys would suffice here
local Range = require "./Range"

local function ForRange<S, T>(
	scope: memory.Scope<S>,
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	processor: iter.ForRangeProcessor<S, T>,
	step: calc.UsedAs<number>?
): iter.For<number, T> | { T }
	local new_range = Range(scope, start, finish, step)

	return ForValues(scope, new_range, processor)
end

return ForRange
