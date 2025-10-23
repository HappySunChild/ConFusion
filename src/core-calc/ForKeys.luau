local calc = require "./types"
local fort = require "./For/types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local doCleanup = require "../core-memory/doCleanup"

local parseError = require "../core-logging/parseError"

local checkDissolvable = require "./For/checkDissolvable"

local Computed = require "./Computed"
local For = require "./For"
local Value = require "./Value"

local SUB_OBJECT_META = table.freeze {
	__index = {
		roamKeys = false,
		roamValues = true,
		invalidateInputKey = function(self): ()
			self._inputKeyState:set(self.inputKey)
		end,
		invalidateInputValue = function(_): ()
			-- do nothing
		end,
		useOutputPair = function(self, use)
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

	object._outputKeyState = Computed(scope, function(use, scope)
		local inputKey = use(object._inputKeyState)
		local ok, outputKey = xpcall(processor, parseError, use, scope, inputKey)

		if ok then
			return outputKey
		end

		local error: logging.Error = outputKey
		External.logErrorNonFatal(logging.callbackError, error)

		doCleanup(scope)

		table.clear(scope)

		return nil
	end)

	return object
end

local function ForKeys<S, IK, IV, OK>(
	scope: memory.Scope<S>,
	inputTable: calc.UsedAs<{ [IK]: IV }>,
	processor: (calc.Use, memory.Scope<S>, IK) -> OK
): calc.For<OK, IV> | { [OK]: IV }
	local can_dissolve, constant = checkDissolvable(scope, inputTable, processor)

	if can_dissolve then
		return constant
	end

	return For(scope, inputTable, function(scope, initialKey, initialValue)
		return SubObject(scope, initialKey, initialValue, processor)
	end)
end

return ForKeys
