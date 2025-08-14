local calc = require "../calc/types"
local memory = require "../memory/types"
local pipeline = require "./types"

local External = require "../External"

local Computed = require "../calc/Computed"
local ForKeys = require "../calc/ForKeys"
local ForPairs = require "../calc/ForPairs"
local ForValues = require "../calc/ForValues"

local Spring = require "../motion/Spring"
local Tween = require "../motion/Tween"

local deriveScope = require "../memory/deriveScope"

type Self<S, T> = pipeline.Pipe<S, T> & {
	_latest: calc.UsedAs<T>,
	_internalScope: memory.Scope<S>,
	_targetScope: memory.Scope<S>,
}

local function _checkFinished(self: Self<any, any>)
	if self._internalScope == nil and self._targetScope == nil then
		External.logError "pipeModifyFrozen"
	end
end

local class = table.freeze {
	type = "Pipe",
	kind = "pipe",

	spring = function<S, T>(
		self: Self<S, T>,
		speed: calc.UsedAs<number>?,
		damping: calc.UsedAs<number>?
	): Self<S, T>
		_checkFinished(self)

		self._latest = Spring(self._internalScope, self._latest, speed, damping)

		return self
	end,
	tween = function<S, T>(self: Self<S, T>, info: calc.UsedAs<TweenInfo>): Self<S, T>
		_checkFinished(self)

		self._latest = Tween(self._internalScope, self._latest, info)

		return self
	end,

	map = function<S, T, O>(
		self: Self<S, T>,
		processor: (value: T, use: calc.Use, scope: memory.Scope<S>) -> O
	): Self<S, O>
		_checkFinished(self)

		local latest = self._latest
		self._latest = Computed(self._internalScope, function(use, scope)
			return processor(use(latest), use, scope)
		end)

		return self
	end,

	forPairs = function<S, IK, IV, OK, OV>(
		self: Self<S, { [IK]: IV }>,
		processor: calc.ForPairsProcessor<
			unknown,
			IK,
			IV,
			OK,
			OV
		>
	): Self<S, { [OK]: OV }>
		_checkFinished(self)

		self._latest = ForPairs(self._internalScope, self._latest, processor)

		return self
	end,
	forValues = function<S, IK, IV, OV>(
		self: Self<S, { [IK]: IV }>,
		processor: calc.ForValuesProcessor<S, IV, OV>
	): Self<S, { [IK]: OV }>
		_checkFinished(self)

		self._latest = ForValues(self._internalScope, self._latest, processor)

		return self
	end,
	forKeys = function<S, IK, IV, OK>(
		self: Self<S, { [IK]: IV }>,
		processor: calc.ForKeysProcessor<S, IK, OK>
	): Self<S, { [OK]: IV }>
		_checkFinished(self)

		self._latest = ForKeys(self._internalScope, self._latest, processor)

		return self
	end,

	finish = function<T>(self: Self<unknown, T>): calc.UsedAs<T>
		_checkFinished(self)

		table.insert(self._targetScope, self._internalScope)

		local latest = self._latest

		self._targetScope = nil
		self._internalScope = nil
		self._latest = nil

		return latest
	end,
}
local METATABLE = table.freeze { __index = class }

local function Pipe<S, T>(
	scope: memory.Scope<S>,
	initialValue: calc.UsedAs<T>
): pipeline.Pipe<S, T>
	local newPipe: Self<S, T> = setmetatable({
		_targetScope = scope,
		_internalScope = deriveScope(scope),

		_latest = initialValue,
	}, METATABLE) :: any

	return newPipe
end

return Pipe
