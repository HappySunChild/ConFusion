local External = require "../External"
local Types = require "../Types"

local doCleanup = require "../Memory/doCleanup"

local Computed = require "./Computed"
local Value = require "./Value"

local For = require "./For"
local ForTypes = require "./For/ForTypes"

local parseError = require "../Logging/parseError"

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
	scope: Types.Scope<S>,
	initialKey: IK,
	initialValue: IV,
	processor: (Types.Use, Types.Scope<S>, IK) -> OK
): ForTypes.SubObject<S, IK, IV, OK, IV>
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

		local error: Types.Error = outputKey
		External.logErrorNonFatal("callbackError", error)
		doCleanup(scope)
		table.clear(scope)

		return nil
	end)

	return object
end

local function ForKeys<S, IK, IV, OK>(
	scope: Types.Scope<S>,
	inputTable: Types.UsedAs<{ [IK]: IV }>,
	processor: (Types.Use, Types.Scope<S>, IK) -> OK
): Types.For<OK, IV>
	return For(scope, inputTable, function(scope, initialKey, initialValue)
		return SubObject(scope, initialKey, initialValue, processor)
	end)
end

return ForKeys
