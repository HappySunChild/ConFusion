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
		roam_values = true,
		invalidateInputKey = function(self): ()
			self._input_key_state:set(self.input_key)
		end,
		invalidateInputValue = function(_): ()
			-- do nothing
		end,
		useOutputPair = function(self, use)
			return use(self._output_key_state), self.input_value
		end,
	},
}

local function SubObject<S, IK, IV, OK>(
	scope: memory.Scope<S>,
	initial_key: IK,
	initial_value: IV,
	processor: iter.ForKeysProcessor<S, IK, OK>
): iter.SubObject<S, IK, IV, OK, IV>
	local object = setmetatable({
		scope = scope,
		input_key = initial_key,
		input_value = initial_value,

		_input_key_state = Value(scope, initial_key),
	}, SUB_OBJECT_META)

	object._output_key_state = Computed(scope, function(use, scope)
		local input_key = use(object._input_key_state)
		local ok, output_key = xpcall(processor, parseError, use, scope, input_key)

		if ok then
			return output_key
		end

		local error: logging.Error = output_key
		External.logErrorNonFatal(logging.callbackError, error)

		doCleanup(scope)

		table.clear(scope)

		return nil
	end)

	return object
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

	return For(scope, input_table, function(scope, initial_key, initial_value)
		return SubObject(scope, initial_key, initial_value, processor)
	end)
end

return ForKeys
