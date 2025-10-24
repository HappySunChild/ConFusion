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
		roamValues = true,
		invalidateInputKey = function(_): ()
			-- do nothing
		end,
		invalidateInputValue = function(self): ()
			self._inputValueState:set(self.inputValue)
		end,
		useOutputPair = function(self, use)
			return self.inputKey, use(self._outputValueState)
		end,
	},
}

local function SubObject<S, IK, IV, OV>(
	scope: memory.Scope<S>,
	initialKey: IK,
	initialValue: IV,
	processor: (calc.Use, memory.Scope<S>, IK) -> OV
): iter.SubObject<S, IK, IV, IK, OV>
	local object = setmetatable({
		scope = scope,
		inputKey = initialKey,
		inputValue = initialValue,

		_inputValueState = Value(scope, initialValue),
	}, SUB_OBJECT_META)

	object._outputValueState = Computed(scope, function(use, scope)
		local inputValue = use(object._inputValueState)
		local ok, outputValue = xpcall(processor, parseError, use, scope, inputValue)

		if ok then
			return outputValue
		end

		local error: logging.Error = outputValue
		External.logErrorNonFatal(logging.callbackError, error)

		doCleanup(scope)

		table.clear(scope)

		return nil
	end)

	return object
end

local function ForValues<S, IK, IV, OV>(
	scope: memory.Scope<S>,
	inputTable: calc.UsedAs<{ [IK]: IV }>,
	processor: (calc.Use, memory.Scope<S>, IV) -> OV
): iter.For<IK, OV> | { [IK]: OV }
	local can_dissolve, constant = checkDissolvable(
		scope,
		inputTable,
		function(use, scope, inputKey, inputValue)
			local newValue = processor(use, scope, inputValue)

			return inputKey, newValue
		end
	)

	if can_dissolve then
		return constant
	end

	return For(scope, inputTable, function(scope, initialKey, initialValue)
		return SubObject(scope, initialKey, initialValue, processor)
	end)
end

return ForValues
