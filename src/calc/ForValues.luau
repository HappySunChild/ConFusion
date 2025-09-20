local calc = require "./types"
local fort = require "./For/types"
local memory = require "../memory/types"

local External = require "../External"

local checkArity = require "../memory/checkArity"
local doCleanup = require "../memory/doCleanup"

local Computed = require "./Computed"
local For = require "./For"
local Value = require "./Value"
local noYield = require "./noYield"

local checkDissolvable = require "./For/checkDissolvable"

local parseError = require "../logging/parseError"

local SUB_OBJECT_META = table.freeze {
	__index = {
		roamKeys = false,
		roamValues = true,
		invalidateInputKey = function() end,
		invalidateInputValue = function<S, IK, IV, OK, OV>(self: fort.SubObject<
			S,
			IK,
			IV,
			OK,
			OV
		>): ()
			self._inputValueState:set(self.inputValue)
		end,
		useOutputPair = function<S, IK, IV, OK, OV>(self: fort.SubObject<S, IK, IV, OK, OV>, use)
			return self.inputKey, use(self._outputValueState)
		end,
	},
}

local function SubObject<S, IK, IV, OV>(
	scope: memory.Scope<S>,
	initialKey: IK,
	initialValue: IV,
	processor: (calc.Use, memory.Scope<S>, IK) -> OV
): fort.SubObject<S, IK, IV, IK, OV>
	local object = setmetatable({
		scope = scope,
		inputKey = initialKey,
		inputValue = initialValue,

		_inputValueState = Value(scope, initialValue),
	}, SUB_OBJECT_META)

	object._outputValueState = Computed(scope, function(use, scope)
		local inputValue = use(object._inputValueState)
		local execOk, yields, outputValue =
			noYield(processor, parseError, use, scope, inputValue)

		if execOk and not yields then
			return outputValue
		end

		doCleanup(scope)

		if yields then
			External.logErrorNonFatal("callbackNoYield", nil, "ForValues")
		else
			External.logErrorNonFatal("callbackError", outputValue)
		end

		return nil
	end)

	return object
end

local function ForValues<S, IK, IV, OV>(
	scope: memory.Scope<S>,
	inputTable: calc.UsedAs<{ [IK]: IV }>,
	processor: (calc.Use, memory.Scope<S>, IV) -> OV
): calc.For<IK, OV> | { [IK]: OV }
	checkArity(processor)

	local canDissolve, constant = checkDissolvable(
		scope,
		inputTable,
		function(use, scope, inputKey, inputValue)
			local newValue = processor(use, scope, inputValue)

			return inputKey, newValue
		end
	)

	if canDissolve then
		return constant
	end

	return For(scope, inputTable, function(scope, initialKey, initialValue)
		return SubObject(scope, initialKey, initialValue, processor)
	end)
end

return ForValues
