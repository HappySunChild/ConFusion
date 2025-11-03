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

type ForValuesComputedPair<IK, IV, OV> = iter.ComputedPair<IK, IV, IK, OV> & {
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
	processor: iter.ForValuesProcessor<
		S,
		IV,
		OV
	>
): ForValuesComputedPair<IK, IV, OV>
	local new_pair = setmetatable({
		scope = scope,
		input_key = initial_key,
		input_value = initial_value,

		_input_value_state = Value(scope, initial_value),
	}, PAIR_METATABLE)

	new_pair._ouput_value_state = Computed(
		scope,
		function(use: calc.Use, calc_scope: memory.Scope<S>)
			local input_value = use(new_pair._input_value_state)

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

	return new_pair
end

local function ForValues<S, IK, IV, OV>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: iter.ForValuesProcessor<S, IV, OV>
): iter.For<IK, OV> | { [IK]: OV }
	local can_dissolve, constant = checkDissolvable(
		scope,
		input_table,
		function(use, scope, input_key, input_value)
			local new_value = processor(use, scope, input_value)

			return input_key, new_value
		end
	)

	if can_dissolve then
		return constant
	end

	return For(scope, input_table, function(scope, initial_key, initial_value)
		return ForValuesComputedPair(scope, initial_key, initial_value, processor)
	end)
end

return ForValues
