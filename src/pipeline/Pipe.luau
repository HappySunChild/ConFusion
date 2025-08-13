local calc = require "../calc/types"
local memory = require "../memory/types"
local pipeline = require "./types"

local Computed = require "../calc/Computed"
local ForKeys = require "../calc/ForKeys"
local ForPairs = require "../calc/ForPairs"
local ForValues = require "../calc/ForValues"
local isSimilar = require "../calc/isSimilar"

local Spring = require "../motion/Spring"
local Tween = require "../motion/Tween"

local deriveScope = require "../memory/deriveScope"
local destructor = require "../memory/destructor"

local castToGraph = require "../graph/castToGraph"
local depend = require "../graph/depend"

local peek = require "../use/peek"

type Self<T> = pipeline.Pipe<T> & {
	_internalScope: memory.Scope,
	_current: calc.UsedAs<T>,
}

local class = table.freeze {
	type = "Pipe",
	kind = "state",
	timeliness = "lazy",

	spring = function<T>(
		self: Self<T>,
		speed: calc.UsedAs<number>?,
		damping: calc.UsedAs<number>?
	): Self<T>
		local newSpring = Spring(self._internalScope, self._current, speed, damping)

		self._current = newSpring

		return self
	end,
	tween = function<T>(self: Self<T>, info: calc.UsedAs<TweenInfo>): Self<T>
		local newTween = Tween(self._internalScope, self._current, info)

		self._current = newTween

		return self
	end,

	map = function<T, O>(
		self: Self<T>,
		processor: (value: T, use: calc.Use, scope: memory.Scope) -> O
	): Self<O>
		local previous = self._current
		local newComputed = Computed(self._internalScope, function(use, scope)
			return processor(use(previous), use, scope)
		end)

		self._current = newComputed

		return self
	end,

	forPairs = function<IK, IV, OK, OV>(
		self: Self<{ [IK]: IV }>,
		processor: calc.ForPairsProcessor<
			unknown,
			IK,
			IV,
			OK,
			OV
		>
	): Self<{ [OK]: OV }>
		local newPairs = ForPairs(self._internalScope, self._current, processor)

		self._current = newPairs

		return self
	end,
	forValues = function<IK, IV, OV>(
		self: Self<{ [IK]: IV }>,
		processor: calc.ForValuesProcessor<unknown, IV, OV>
	): Self<{ [IK]: OV }>
		local newValues = ForValues(self._internalScope, self._current, processor)

		self._current = newValues

		return self
	end,
	forKeys = function<IK, IV, OK>(
		self: Self<{ [IK]: IV }>,
		processor: calc.ForKeysProcessor<unknown, IK, OK>
	): Self<{ [OK]: IV }>
		local newKeys = ForKeys(self._internalScope, self._current, processor)

		self._current = newKeys

		return self
	end,

	_evaluate = function(self: Self<unknown>)
		if castToGraph(self._current) then
			depend(self, self._current)
		end

		local newValue = peek(self._current)
		local oldValue = self._internalValue

		self._internalValue = newValue

		return not isSimilar(newValue, oldValue)
	end,
}
local METATABLE = table.freeze { __index = class }

local function Pipe<V>(scope: memory.Scope, rootInput: calc.UsedAs<V>): pipeline.Pipe<V>
	local newPipe: Self<V> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_current = rootInput,
		_internalValue = peek(rootInput),
		_internalScope = deriveScope(scope),

		_users = {},
		_using = {},
	}, METATABLE) :: any

	table.insert(scope, {
		destructor(newPipe),
		newPipe._internalScope,
	})

	return newPipe
end

return Pipe
