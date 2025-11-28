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

type ForKeysComputedPair<IK, IV, OK> = iter_for.ComputedPair<IK, IV, OK, IV> & {
	_input_key_state: calc.Value<IK>,
	_output_key_state: calc.Computed<OK>,
}

local PAIR_CLASS = table.freeze {
	invalidate_input_key = function<IK, IV, OK>(self: ForKeysComputedPair<IK, IV, OK>): ()
		self._input_key_state:set(self.input_key)
	end,
	invalidate_input_value = function<S, IK, IV, OK>(): () end,

	use_output_pair = function<IK, IV, OK>(
		self: ForKeysComputedPair<IK, IV, OK>,
		use: calc.Use
	): (OK, IV)
		return use(self._output_key_state), self.input_value
	end,
}
local PAIR_METATABLE = table.freeze { __index = PAIR_CLASS }

local function ForKeysComputedPair<S, IK, IV, OK>(
	scope: memory.Scope<S>,
	initial_key: IK,
	initial_value: IV,
	processor: iter_for.ForKeysProcessor<
		S,
		IK,
		OK
	>
): ForKeysComputedPair<IK, IV, OK>
	local input_key_state = Value(scope, initial_key)
	local output_key_state = Computed(
		scope,
		function(use: calc.Use, calc_scope: memory.Scope<S>)
			local input_key = use(input_key_state)
			local ok, output_key =
				xpcall(processor, parse_error, use, calc_scope, input_key)

			if ok then
				return output_key
			end

			External.log_error_non_fatal(calc.callback_error, output_key :: logging.Error)

			destroy(calc_scope)

			return nil
		end
	)

	local new_computedpair = setmetatable({
		scope = scope,
		input_key = initial_key,
		input_value = initial_value,

		_input_key_state = input_key_state,
		_output_key_state = output_key_state,
	}, PAIR_METATABLE)

	return new_computedpair
end

local function ForKeys<S, IK, IV, OK>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: iter_for.ForKeysProcessor<S, IK, OK>
): iter.Iter<OK, IV> | { [OK]: IV }
	local can_dissolve, constant = check_dissolvable(scope, input_table, processor)

	if can_dissolve then
		return constant
	end

	return Iter(
		scope,
		ForDisassembly(
			scope,
			false,
			true,
			input_table,
			function(scope: memory.Scope<S>, initial_key: IK, initial_value: IV)
				return ForKeysComputedPair(scope, initial_key, initial_value, processor)
			end
		)
	)
end

return ForKeys
