local calc = require "../core-calc/types"
local iter = require "./types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local Computed = require "../core-calc/Computed"
local External = require "../core-external/External"
local For = require "./For"
local Value = require "../core-calc/Value"
local checkDissolvable = require "./For/checkDissolvable"
local doCleanup = require "../core-memory/doCleanup"
local parseError = require "../core-logging/parseError"

type ForPairsComputedPair<IK, IV, OK, OV> = iter.ComputedPair<IK, IV, OK, OV> & {
	_input_key_state: calc.Value<IK>,
	_input_value_state: calc.Value<IV>,
	_output_pair_state: calc.Computed<{ key: OK, value: OV }>,
}

local PAIR_CLASS = table.freeze {
	roam_keys = false,
	roam_values = false,

	invalidateInputKey = function<IK, IV, OK, OV>(self: ForPairsComputedPair<IK, IV, OK, OV>): ()
		self._input_key_state:set(self.input_key)
	end,
	invalidateInputValue = function<IK, IV, OK, OV>(self: ForPairsComputedPair<IK, IV, OK, OV>): ()
		self._input_value_state:set(self.input_value)
	end,

	useOutputPair = function<IK, IV, OK, OV>(
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
	processor: iter.ForPairsProcessor<
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
	local new_pair = setmetatable({
		scope = scope,
		input_key = initial_key,
		input_value = initial_value,

		_input_value_state = Value(scope, initial_value),
		_input_key_state = Value(scope, initial_key),
	}, PAIR_METATABLE)

	new_pair._output_pair_state = Computed(
		scope,
		function(use: calc.Use, calc_scope: memory.Scope<S>)
			local input_key = use(new_pair._input_key_state)
			local input_value = use(new_pair._input_value_state)

			local ok, output_key, output_value =
				xpcall(processor, parseError, use, calc_scope, input_key, input_value)

			if ok then
				return { key = output_key, value = output_value }
			end

			External.logErrorNonFatal(calc.callback_error, output_key :: logging.Error)

			doCleanup(calc_scope)

			return { key = nil, value = nil }
		end
	)

	return new_pair
end

local function ForPairs<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: iter.ForPairsProcessor<S, IK, IV, OK, OV>
): iter.For<OK, OV> | { [OK]: OV }
	local can_dissolve, constant = checkDissolvable(scope, input_table, processor)

	if can_dissolve then
		return constant
	end

	return For(
		scope,
		input_table,
		function(scope: memory.Scope<S>, initial_key: IK, initial_value: IV)
			return ForPairsComputedPair(scope, initial_key, initial_value, processor)
		end
	)
end

return ForPairs
