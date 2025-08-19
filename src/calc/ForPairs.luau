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
		roamValues = false,
		invalidateInputKey = function<S, IK, IV, OK, OV>(self: fort.SubObject<
			S,
			IK,
			IV,
			OK,
			OV
		>): ()
			self._inputKeyState:set(self.inputKey)
		end,
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
			local pair = use(self._outputPairState)
			return pair.key, pair.value
		end,
	},
}

local function SubObject<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	initialKey: IK,
	initialValue: IV,
	processor: (
		calc.Use,
		memory.Scope<S>,
		IK,
		IV
	) -> (OK, OV)
): fort.SubObject<S, IK, IV, OK, OV>
	local object = setmetatable({
		scope = scope,
		inputKey = initialKey,
		inputValue = initialValue,

		_inputValueState = Value(scope, initialValue),
		_inputKeyState = Value(scope, initialKey),
	}, SUB_OBJECT_META)

	object._outputPairState = Computed(scope, function(use, scope)
		local inputKey = use(object._inputKeyState)
		local inputValue = use(object._inputValueState)
		local execOk, yields, outputKey, outputValue =
			noYield(processor, parseError, use, scope, inputKey, inputValue)

		if execOk and not yields then
			return { key = outputKey, value = outputValue }
		end

		doCleanup(scope)

		if yields then
			External.logErrorNonFatal("callbackNoYield", nil, "ForPairs")
		else
			External.logErrorNonFatal("callbackError", outputKey)
		end

		return { key = nil, value = nil }
	end)

	return object
end

local function ForPairs<S, IK, IV, OK, OV>(
	scope: memory.Scope<S>,
	inputTable: calc.UsedAs<{ [IK]: IV }>,
	processor: (
		calc.Use,
		memory.Scope<S>,
		IK,
		IV
	) -> (OK, OV)
): calc.For<OK, OV> | { [OK]: OV }
	checkArity(processor)

	local canDissolve, constant = checkDissolvable(scope, inputTable, processor)

	if canDissolve then
		return constant
	end

	return For(scope, inputTable, function(scope, initialKey, initialValue)
		return SubObject(scope, initialKey, initialValue, processor)
	end)
end

return ForPairs
