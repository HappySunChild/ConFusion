local calc = require "../core-calc/types"
local iter = require "./types"
local memory = require "../core-memory/types"

local castToState = require "../core-calc/castToState"
local depend = require "../core-graph/depend"
local destructor = require "../core-memory/destructor"
local peek = require "../core-use/peek"

type Self = iter.Range & {
	_start: calc.UsedAs<number>,
	_finish: calc.UsedAs<number>,
	_step: calc.UsedAs<number>,
}

local function checkDissolvable(
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	step: calc.UsedAs<number>
): (boolean, { number }?)
	if
		castToState(start) ~= nil
		or castToState(finish) ~= nil
		or castToState(step) ~= nil
	then
		return false
	end

	start = start :: number
	finish = finish :: number
	step = step :: number

	local output = table.create(math.ceil((finish - start) / step))

	for i = start, finish, step do
		output[i] = i
	end

	return true, output
end

local CLASS = table.freeze {
	type = "Range",
	kind = "state",
	timeliness = "lazy",

	_evaluate = function(self: Self)
		if castToState(self._start) then
			depend(self, self._start)
		end

		if castToState(self._finish) then
			depend(self, self._finish)
		end

		if castToState(self._step) then
			depend(self, self._step)
		end

		local output = self._internal_value

		for i = peek(self._start), peek(self._finish), peek(self._step) do
			output[i] = i
		end

		return true
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function Range(
	scope: memory.Scope,
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	step: calc.UsedAs<number>?
): iter.Range | { number }
	step = step or 1

	local can_dissolve, constant = checkDissolvable(start, finish, step)

	if can_dissolve then
		return constant
	end

	local new_range = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_using = {},
		_users = {},
		_internal_value = {},

		_start = start,
		_finish = finish,
		_step = step,
	}, METATABLE)

	table.insert(scope, destructor(new_range))

	return new_range
end

return Range
