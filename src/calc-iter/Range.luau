local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

local castToState = require "../core-calc/castToState"
local depend = require "../core-graph/depend"
local destructor = require "../core-memory/destructor"
local peek = require "../core-use/peek"

type Self = calc.StateObject<{ number }> & {
	_start: calc.UsedAs<number>,
	_finish: calc.UsedAs<number>,
	_step: calc.UsedAs<number>,
}

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
)
	step = step or 1

	local new_range = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_start = start,
		_finish = finish,
		_step = step,

		_internal_value = {},
	}, METATABLE)

	table.insert(scope, destructor(new_range))

	return new_range
end

return Range
