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
		invalidateInputKey = function(_): ()
			-- do nothing
		end,
		invalidateInputValue = function(self): ()
			self._input_value_state:set(self.input_value)
		end,
		useOutputPair = function(self, use)
			return self.input_key, use(self._ouput_value_state)
		end,
	},
}

local function SubObject<S, IK, IV, OV>(
	scope: memory.Scope<S>,
	initial_key: IK,
	initial_value: IV,
	processor: iter.ForValuesProcessor<S, IV, OV>
): iter.SubObject<S, IK, IV, IK, OV>
	local object = setmetatable({
		scope = scope,
		input_key = initial_key,
		input_value = initial_value,

		_input_value_state = Value(scope, initial_value),
	}, SUB_OBJECT_META)

	object._ouput_value_state = Computed(scope, function(use, scope)
		local input_value = use(object._input_value_state)
		local ok, output_value = xpcall(processor, parseError, use, scope, input_value)

		if ok then
			return output_value
		end

		local error: logging.Error = output_value
		External.logErrorNonFatal(logging.callback_error, error)

		doCleanup(scope)

		table.clear(scope)

		return nil
	end)

	return object
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
		return SubObject(scope, initial_key, initial_value, processor)
	end)
end

return ForValues
