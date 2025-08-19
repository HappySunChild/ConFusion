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
		invalidateInputKey = function<S, IK, IV, OK, OV>(self: fort.SubObject<
			S,
			IK,
			IV,
			OK,
			OV
		>): ()
			self._inputKeyState:set(self.inputKey)
		end,
		invalidateInputValue = function() end,
		useOutputPair = function<S, IK, IV, OK, OV>(self: fort.SubObject<S, IK, IV, OK, OV>, use)
			return use(self._outputKeyState), self.inputValue
		end,
	},
}

local function SubObject<S, IK, IV, OK>(
	scope: memory.Scope<S>,
	initialKey: IK,
	initialValue: IV,
	processor: (calc.Use, memory.Scope<S>, IK) -> OK
): fort.SubObject<S, IK, IV, OK, IV>
	local object = setmetatable({
		scope = scope,
		inputKey = initialKey,
		inputValue = initialValue,

		_inputKeyState = Value(scope, initialKey),
	}, SUB_OBJECT_META)

	object._outputKeyState = Computed(
		scope,
		function(use: calc.Use, scope: memory.Scope<S>)
			local inputKey = use(object._inputKeyState)
			local execOk, yields, outputKey =
				noYield(processor, parseError, use, scope, inputKey)

			if execOk and not yields then
				return outputKey
			end

			doCleanup(scope)

			if yields then
				External.logErrorNonFatal("callbackNoYield", nil, "ForKeys")
			else
				External.logErrorNonFatal("callbackError", outputKey)
			end

			return nil
		end
	)

	return object
end

local function ForKeys<S, IK, IV, OK>(
	scope: memory.Scope<S>,
	inputTable: calc.UsedAs<{ [IK]: IV }>,
	processor: (calc.Use, memory.Scope<S>, IK) -> OK
): calc.For<OK, IV> | { [OK]: IV }
	checkArity(processor)

	local canDissolve, constant = checkDissolvable(scope, inputTable, processor)

	if canDissolve then
		return constant
	end

	return For(scope, inputTable, function(scope, initialKey, initialValue)
		return SubObject(scope, initialKey, initialValue, processor)
	end)
end

return ForKeys
