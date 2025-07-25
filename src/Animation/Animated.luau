--!strict
local External = require "../External"
local Types = require "../Types"

local Timer = require "./Timer"

local change = require "../Graph/change"
local depend = require "../Graph/depend"
local evaluate = require "../Graph/evaluate"

local castToState = require "../State/castToState"
local peek = require "../State/peek"

type Self<V> = Types.Animated<V> & {
	_goal: Types.UsedAs<V>,
	_activeStart: V,
	_activeGoal: V,

	_generator: Types.UsedAs<Types.CurveGenerator<V>>,
	_activeGenerator: Types.CurveGenerator<V>,
	_activeCurve: Types.AnimationCurve<V>,

	_activeState: { any },

	_shouldRegenerate: boolean?,

	_timer: Types.Timer,
}

local function _syncFromCurve<V>(
	inPlaceState: { any },
	shouldSleep: boolean,
	outputValue: V,
	...: any
): (boolean, V)
	-- clear and update state in place, instead of constructing a new table
	table.clear(inPlaceState)

	for i = 1, select("#", ...) do
		inPlaceState[i] = select(i, ...)
	end

	return shouldSleep, outputValue
end

local class = table.freeze {
	type = "Animated",
	kind = "state",
	timeliness = "eager",

	writeState = function<V>(self: Self<V>, index: number, value: any)
		self._activeState[index] = value
		self._shouldRegenerate = true

		change(self)
	end,
	readState = function<V>(self: Self<V>, index: number)
		return self._activeState[index]
	end,
	_evaluate = function<V>(self: Self<V>)
		local goal = self._goal
		local generator = self._generator
		local timer = self._timer

		local nextGoal = peek(goal)
		local nextGenerator = peek(generator) :: Types.CurveGenerator<V>

		if castToState(generator) then
			depend(self, generator :: any)
		end

		if castToState(goal) then
			depend(self, goal)
		end

		depend(self, timer)

		-- wake
		if
			nextGoal ~= self._activeGoal :: any
			or nextGenerator ~= self._activeGenerator
			or self._shouldRegenerate == true
		then
			self._shouldRegenerate = nil

			self._activeStart = self._internalValue
			self._activeGoal = nextGoal

			self._activeGenerator = nextGenerator
			self._activeCurve = nextGenerator(
				self._activeStart,
				self._activeGoal,
				unpack(self._activeState)
			)

			timer:reset()
			timer:unpause()
		end

		local elapsed = peek(timer) :: number

		if elapsed == 0 then
			elapsed = External.getDeltaTime()
		end

		local oldValue = self._internalValue :: any
		local shouldSleep, newValue =
			_syncFromCurve(self._activeState, self._activeCurve(elapsed))

		self._internalValue = newValue

		-- sleep
		if shouldSleep then
			timer:pause()
		end

		return (oldValue :: any) ~= (newValue :: any)
	end,
}
local METATABLE = table.freeze { __index = class }

local function Animated<V>(
	scope: Types.Scope,
	goal: Types.UsedAs<V>,
	mover: Types.UsedAs<Types.CurveGenerator<V>>
): Types.Animated<V>
	local timer = Timer(scope)
	local newAnimated: Self<V> = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = peek(goal),

		_using = {},
		_users = {},

		_goal = goal,
		_activeStart = nil,
		_activeGoal = nil,

		_generator = mover,
		_activeGenerator = nil,
		_activeCurve = nil,

		_activeState = {},

		_timer = timer,
	}, METATABLE) :: any

	evaluate(newAnimated, true)

	return newAnimated
end

return Animated
