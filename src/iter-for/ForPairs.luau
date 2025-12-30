local calc = require "../core-calc/types"
local iter = require "../iter/types"
local iter_for = require "./types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local Computed = require "../core-calc/Computed"
local Value = require "../core-calc/Value"

local destroy = require "../core-memory/destroy"

local parse_error = require "../core-logging/parse_error"

local Iter = require "../iter/Iter"

local ForDisassembly = require "./ForDisassembly"
local check_dissolvable = require "./check_dissolvable"

type ForPairsComputedPair<IK, IV, OK, OV> = iter_for.ComputedPair<IK, IV, OK, OV> & {
	_input_key_state: calc.Value<IK>,
	_input_value_state: calc.Value<IV>,
	_output_pair_state: calc.Computed<{ key: OK, value: OV }>,
}

local PAIR_CLASS = table.freeze {
	invalidate_input_key = function<IK, IV, OK, OV>(self: ForPairsComputedPair<IK, IV, OK, OV>): ()
		self._input_key_state:set(self.input_key)
	end,
	invalidate_input_value = function<IK, IV, OK, OV>(self: ForPairsComputedPair<
		IK,
		IV,
		OK,
		OV
	>): ()
		self._input_value_state:set(self.input_value)
	end,

	use_output_pair = function<IK, IV, OK, OV>(
		self: ForPairsComputedPair<IK, IV, OK, OV>,
		use: calc.Use
	): (OK, OV)
		local pair = use(self._output_pair_state)

		return pair.key, pair.value
	end,
}
local PAIR_METATABLE = table.freeze { __index = PAIR_CLASS }

local function ForPairsComputedPair<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	initial_key: IK,
	initial_value: IV,
	processor: iter_for.ForPairsProcessor<
		S,
		IK,
		IV,
		OK,
		OV
	>
): ForPairsComputedPair<
	IK,
	IV,
	OK,
	OV
>
	local input_value_state = Value(scope, initial_value)
	local input_key_state = Value(scope, initial_key)
	local output_pair_state = Computed(
		scope,
		function(use: calc.Use, calc_scope: memory.Scope<S>)
			local input_key = use(input_key_state)
			local input_value = use(input_value_state)
			local ok, output_key, output_value =
				xpcall(processor, parse_error, use, calc_scope, input_key, input_value)

			if ok then
				return { key = output_key, value = output_value }
			end

			External.log_error_nonfatal(calc.callback_error, output_key :: logging.Error)

			destroy(calc_scope)

			return { key = nil, value = nil }
		end
	)

	local new_computedpair = setmetatable({
		scope = scope,
		input_key = initial_key,
		input_value = initial_value,

		_input_key_state = input_key_state,
		_input_value_state = input_value_state,
		_output_pair_state = output_pair_state,
	}, PAIR_METATABLE)

	return new_computedpair
end

local function ForPairs<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: iter_for.ForPairsProcessor<
		S,
		IK,
		IV,
		OK,
		OV
	>
): iter.Iter<OK, OV> | { [OK]: OV }
	local can_dissolve, constant = check_dissolvable(scope, input_table, processor)

	if can_dissolve then
		return constant
	end

	return Iter(
		scope,
		ForDisassembly(
			scope,
			false,
			false,
			input_table,
			function(scope: memory.Scope<S>, initial_key: IK, initial_value: IV)
				return ForPairsComputedPair(scope, initial_key, initial_value, processor)
			end
		)
	)
end

return ForPairs
