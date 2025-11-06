local calc = require "../core-calc/types"
local iter_for = require "../iter-for/types"
local memory = require "../core-memory/types"
local pipeline = require "./types"
local tweens = require "../motion-tweens/types"

local Computed = require "../core-calc/Computed"
local ForKeys = require "../iter-for/ForKeys"
local ForPairs = require "../iter-for/ForPairs"
local ForValues = require "../iter-for/ForValues"
local Spring = require "../motion-springs/Spring"
local Tween = require "../motion-tweens/Tween"
local innerScope = require "../core-memory/innerScope"

type Self<S, T> = pipeline.Pipe<S, T> & {
	_latest: calc.UsedAs<T>,
	_internal_scope: memory.Scope<S>,
}

local CLASS = table.freeze {
	type = "Pipe",
	kind = "pipe",

	spring = function<S, T>(
		self: Self<S, T>,
		speed: calc.UsedAs<number>?,
		damping: calc.UsedAs<number>?
	): Self<S, T>
		self._latest = Spring(self._internal_scope, self._latest, speed, damping)

		return self
	end,
	tween = function<S, T>(self: Self<S, T>, info: calc.UsedAs<tweens.TweenInfo>): Self<S, T>
		self._latest = Tween(self._internal_scope, self._latest, info)

		return self
	end,

	map = function<S, T, O>(
		self: Self<S, T>,
		processor: (value: T, use: calc.Use, scope: memory.Scope<S>) -> O
	): Self<S, O>
		local latest = self._latest
		self._latest = Computed(self._internal_scope, function(use, scope)
			return processor(use(latest), use, scope)
		end)

		return self
	end,

	forPairs = function<S, IK, IV, OK, OV>(
		self: Self<S, { [IK]: IV }>,
		processor: iter_for.ForPairsProcessor<
			unknown,
			IK,
			IV,
			OK,
			OV
		>
	): Self<S, { [OK]: OV }>
		self._latest = ForPairs(self._internal_scope, self._latest, processor)

		return self
	end,
	forValues = function<S, IK, IV, OV>(
		self: Self<S, { [IK]: IV }>,
		processor: iter_for.ForValuesProcessor<S, IV, OV>
	): Self<S, { [IK]: OV }>
		self._latest = ForValues(self._internal_scope, self._latest, processor)

		return self
	end,
	forKeys = function<S, IK, IV, OK>(
		self: Self<S, { [IK]: IV }>,
		processor: iter_for.ForKeysProcessor<S, IK, OK>
	): Self<S, { [OK]: IV }>
		self._latest = ForKeys(self._internal_scope, self._latest, processor)

		return self
	end,

	resolve = function<T>(self: Self<unknown, T>): calc.UsedAs<T>
		return self._latest
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function Pipe<S, T>(
	scope: memory.Scope<S>,
	initial_value: calc.UsedAs<T>
): pipeline.Pipe<S, T>
	local new_pipe: Self<S, T> = setmetatable({
		_internal_scope = innerScope(scope),
		_latest = initial_value,
	}, METATABLE) :: any

	return new_pipe
end

return Pipe
