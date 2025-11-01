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

type ForKeysPair<IK, IV, OK> = iter.Pair<IK, IV, OK, IV> & {
	_input_key_state: calc.Value<IK>,
	_output_key_state: calc.Computed<OK>,
}

local PAIR_CLASS = table.freeze {
	roam_keys = false,
	roam_values = true,

	invalidateInputKey = function<IK, IV, OK>(self: ForKeysPair<IK, IV, OK>): ()
		self._input_key_state:set(self.input_key)
	end,
	invalidateInputValue = function<S, IK, IV, OK>(): () end,

	useOutputPair = function<IK, IV, OK>(self: ForKeysPair<IK, IV, OK>, use: calc.Use): (OK, IV)
		return use(self._output_key_state), self.input_value
	end,
}
local PAIR_METATABLE = table.freeze { __index = PAIR_CLASS }

local function ForKeysPair<S, IK, IV, OK>(
	scope: memory.Scope<S>,
	initial_key: IK,
	initial_value: IV,
	processor: iter.ForKeysProcessor<S, IK, OK>
): ForKeysPair<IK, IV, OK>
	local new_pair = setmetatable({
		scope = scope,
		input_key = initial_key,
		input_value = initial_value,

		_input_key_state = Value(scope, initial_key),
	}, PAIR_METATABLE)

	new_pair._output_key_state = Computed(
		scope,
		function(use: calc.Use, calc_scope: memory.Scope<S>)
			local input_key = use(new_pair._input_key_state)

			local ok, output_key =
				xpcall(processor, parseError, use, calc_scope, input_key)

			if ok then
				return output_key
			end

			External.logErrorNonFatal(calc.callback_error, output_key :: logging.Error)

			doCleanup(calc_scope)

			return nil
		end
	)

	return new_pair
end

local function ForKeys<S, IK, IV, OK>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: iter.ForKeysProcessor<S, IK, OK>
): iter.For<OK, IV> | { [OK]: IV }
	local can_dissolve, constant = checkDissolvable(scope, input_table, processor)

	if can_dissolve then
		return constant
	end

	return For(
		scope,
		input_table,
		function(scope: memory.Scope<S>, initial_key: IK, initial_value: IV)
			return ForKeysPair(scope, initial_key, initial_value, processor)
		end
	)
end

return ForKeys
