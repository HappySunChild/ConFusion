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

local SUB_OBJECT_META = table.freeze {
	__index = {
		roam_keys = false,
		roam_values = false,
		invalidateInputKey = function(self): ()
			self._input_key_state:set(self.input_key)
		end,
		invalidateInputValue = function(self): ()
			self._input_value_state:set(self.input_value)
		end,
		useOutputPair = function(self, use)
			local pair = use(self._output_pair_state)
			return pair.key, pair.value
		end,
	},
}

local function SubObject<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	initial_key: IK,
	initial_value: IV,
	processor: iter.ForPairsProcessor<S, IK, IV, OK, OV>
): iter.SubObject<S, IK, IV, OK, OV>
	local object = setmetatable({
		scope = scope,
		input_key = initial_key,
		input_value = initial_value,

		_input_value_state = Value(scope, initial_value),
		_input_key_state = Value(scope, initial_key),
	}, SUB_OBJECT_META)

	object._output_pair_state = Computed(scope, function(use, scope)
		local input_key = use(object._input_key_state)
		local input_value = use(object._input_value_state)
		local ok, output_key, output_value =
			xpcall(processor, parseError, use, scope, input_key, input_value)

		if ok then
			return { key = output_key, value = output_value }
		end

		local err: logging.Error = output_key
		External.logErrorNonFatal(logging.callbackError, err)

		doCleanup(scope)

		table.clear(scope)

		return { key = nil, value = nil }
	end)

	return object
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

	return For(scope, input_table, function(scope, initial_key, initial_value)
		return SubObject(scope, initial_key, initial_value, processor)
	end)
end

return ForPairs
