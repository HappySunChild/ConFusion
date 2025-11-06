local calc = require "../core-calc/types"
local iter = require "../iter/types"
local iter_range = require "./types"
local memory = require "../core-memory/types"

local Iter = require "../iter/Iter"
local RangeDisassembly = require "./RangeDisassembly"
local castToState = require "../core-calc/castToState"
local destroy = require "../core-memory/destroy"
local dissolvingUse = require "../core-use/dissolvingUse"
local innerScope = require "../core-memory/innerScope"

local function checkDissolvable<S, T>(
	scope: memory.Scope<S>,
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	step: calc.UsedAs<number>,
	processor: iter_range.RangeDisassemblyProcessor<S, T>
): (boolean, { [number]: T }?)
	if
		castToState(start) ~= nil
		or castToState(finish) ~= nil
		or castToState(step) ~= nil
	then
		return false
	end

	local dissolving_scope = innerScope(scope)

	local output = {}

	for index = start :: number, finish :: number, step :: number do
		local ok, value = pcall(processor, dissolvingUse, dissolving_scope, index)

		if not ok then
			destroy(dissolving_scope)

			return false, nil
		end

		output[index] = value
	end

	return true, output
end

local function ForRange<S, T>(
	scope: memory.Scope<S>,
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	processor: iter_range.RangeDisassemblyProcessor<S, T>,
	step: calc.UsedAs<number>?
): iter.Iter<number, T> | { T }
	step = step or 1

	local can_dissolve, constant = checkDissolvable(scope, start, finish, step, processor)

	if can_dissolve then
		return constant
	end

	return Iter(scope, RangeDisassembly(scope, processor, start, finish, step))
end

return ForRange
