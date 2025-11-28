local calc = require "../core-calc/types"
local iter = require "../iter/types"
local iter_range = require "./types"
local memory = require "../core-memory/types"

local cast_to_state = require "../core-calc/cast_to_state"

local peek = require "../core-use/peek"

local depend = require "../core-graph/depend"

local derive_scope = require "../core-memory/derive_scope"
local destroy = require "../core-memory/destroy"
local destructor = require "../core-memory/destructor"

local RangePair = require "./RangePair"

type Self<S, V> = {
	_start: calc.UsedAs<number>,
	_finish: calc.UsedAs<number>,
	_step: calc.UsedAs<number>,

	_pairs: { iter_range.RangePair<V> },
	_processor: iter_range.RangeDisassemblyProcessor<S, V>,
} & iter.Disassembly<number, V>

local CLASS = table.freeze {
	type = "Graph",
	kind = "Disassembly",
	timeliness = "lazy",

	populate = function<S, V>(self: Self<S, V>, use: calc.Use, output: { [number]: V })
		for index, object in self._pairs do
			output[index] = object:useOutput(use)
		end
	end,
	_evaluate = function<S, V>(self: Self<S, V>)
		depend(self, cast_to_state(self._start))
		depend(self, cast_to_state(self._finish))
		depend(self, cast_to_state(self._step))

		local outer_scope = self.scope

		local current_pairs = self._pairs
		local next_pairs = {}

		for new_index = peek(self._start), peek(self._finish), peek(self._step) do
			-- directly reuse objects that are the same
			if current_pairs[new_index] ~= nil then
				next_pairs[new_index] = current_pairs[new_index]
				current_pairs[new_index] = nil

				continue
			end

			-- reuse any existing objects that can be repurposed
			local old_index, reuse_object = next(current_pairs)

			if reuse_object ~= nil then
				current_pairs[old_index] = nil

				reuse_object.input_index = new_index
				reuse_object:invalidate()

				next_pairs[new_index] = reuse_object

				continue
			end

			-- create a new object if none are available
			next_pairs[new_index] =
				RangePair(derive_scope(outer_scope), new_index, self._processor)
		end

		-- clean up remaining objects
		for _, object in current_pairs do
			destroy(object.scope)
		end

		self._pairs = next_pairs

		return true
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function auxiliary_destructor<S, V>(disassembly: Self<S, V>)
	for _, object in disassembly._pairs do
		destroy(object.scope)
	end
end

local function RangeDisassembly<S, V>(
	scope: memory.Scope<S>,
	processor: iter_range.RangeDisassemblyProcessor<S, V>,
	start: calc.UsedAs<number>,
	finish: calc.UsedAs<number>,
	step: calc.UsedAs<number>?
): iter.Disassembly<number, V>
	step = step or 1

	local new_disassembly: Self<S, V> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_users = {},
		_using = {},

		_start = start,
		_finish = finish,
		_step = step,

		_pairs = {},
		_processor = processor,
	}, METATABLE) :: any

	table.insert(scope, destructor(new_disassembly, auxiliary_destructor))

	return new_disassembly
end

return RangeDisassembly
