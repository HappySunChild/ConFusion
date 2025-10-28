local calc = require "../core-calc/types"
local iter = require "./types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local Computed = require "../core-calc/Computed"
local Value = require "../core-calc/Value"

local doCleanup = require "../core-memory/doCleanup"

local parseError = require "../core-logging/parseError"

local For = require "./For"
local checkDissolvable = require "./For/checkDissolvable"

local SUB_OBJECT_META = table.freeze {
	__index = {
		roamKeys = false,
		roamValues = false,
		invalidateInputKey = function(self): ()
			self._inputKeyState:set(self.inputKey)
		end,
		invalidateInputValue = function(self): ()
			self._inputValueState:set(self.inputValue)
		end,
		useOutputPair = function(self, use)
			local pair = use(self._outputPairState)
			return pair.key, pair.value
		end,
	},
}

local function SubObject<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	initialKey: IK,
	initialValue: IV,
	processor: iter.ForPairsProcessor<S, IK, IV, OK, OV>
): iter.SubObject<S, IK, IV, OK, OV>
	local object = setmetatable({
		scope = scope,
		inputKey = initialKey,
		inputValue = initialValue,

		_inputValueState = Value(scope, initialValue),
		_inputKeyState = Value(scope, initialKey),
	}, SUB_OBJECT_META)

	object._outputPairState = Computed(scope, function(use, scope)
		local input_key = use(object._inputKeyState)
		local input_value = use(object._inputValueState)
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
