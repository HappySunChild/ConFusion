local calc = require "../core-calc/types"
local iter = require "../iter/types"
local iter_for = require "./types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local Computed = require "../core-calc/Computed"
local External = require "../core-external/External"
local ForDisassembly = require "./ForDisassembly"
local Iter = require "../iter/Iter"
local Value = require "../core-calc/Value"
local checkDissolvable = require "./checkDissolvable"
local doCleanup = require "../core-memory/doCleanup"
local parseError = require "../core-logging/parseError"

type ForValuesComputedPair<IK, IV, OV> = iter_for.ComputedPair<IK, IV, IK, OV> & {
	_input_value_state: calc.Value<IV>,
	_output_value_state: calc.Computed<OV>,
}

local PAIR_CLASS = table.freeze {
	roam_keys = true,
	roam_values = false,

	invalidateInputKey = function(): () end,
	invalidateInputValue = function<IK, IV, OV>(self: ForValuesComputedPair<IK, IV, OV>): ()
		self._input_value_state:set(self.input_value)
	end,

	useOutputPair = function<IK, IV, OV>(
		self: ForValuesComputedPair<IK, IV, OV>,
		use: calc.Use
	): (IK, OV)
		return self.input_key, use(self._ouput_value_state)
	end,
}
local PAIR_METATABLE = table.freeze { __index = PAIR_CLASS }

local function ForValuesComputedPair<S, IK, IV, OV>(
	scope: memory.Scope<S>,
	initial_key: IK,
	initial_value: IV,
	processor: iter_for.ForValuesProcessor<
		S,
		IV,
		OV
	>
): ForValuesComputedPair<IK, IV, OV>
	local new_computedpair = setmetatable({
		scope = scope,
		input_key = initial_key,
		input_value = initial_value,

		_input_value_state = Value(scope, initial_value),
	}, PAIR_METATABLE)

	new_computedpair._ouput_value_state = Computed(
		scope,
		function(use: calc.Use, calc_scope: memory.Scope<S>)
			local input_value = use(new_computedpair._input_value_state)

			local ok, output_value =
				xpcall(processor, parseError, use, calc_scope, input_value)

			if ok then
				return output_value
			end

			External.logErrorNonFatal(calc.callback_error, output_value :: logging.Error)

			doCleanup(calc_scope)

			return nil
		end
	)

	return new_computedpair
end

local function ForValues<S, IK, IV, OV>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: iter_for.ForValuesProcessor<S, IV, OV>
): iter.Iter<IK, OV> | { [IK]: OV }
	local can_dissolve, constant = checkDissolvable(
		scope,
		input_table,
		function(use: calc.Use, scope: memory.Scope<S>, input_key: IK, input_value: IV)
			local new_value = processor(use, scope, input_value)

			return input_key, new_value
		end
	)

	if can_dissolve then
		return constant
	end

	return Iter(
		scope,
		ForDisassembly(
			scope,
			input_table,
			function(scope: memory.Scope<S>, initial_key: IK, initial_value: IV)
				return ForValuesComputedPair(scope, initial_key, initial_value, processor)
			end
		)
	)
end

return ForValues
