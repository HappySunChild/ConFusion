--!strict
local External = require "../External"
local Types = require "../Types"

local Timer = require "./Timer"

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

	_timer: Types.Timer,
}

local class = table.freeze {
	type = "Animated",
	kind = "state",
	timeliness = "eager",

	_evaluate = function<V>(self: Self<V>)
		local goal = self._goal

		if not castToState(self._goal) then
			return false
		end

		local generator = self._generator
		local timer = self._timer

		local nextGoal = peek(goal)
		local nextGenerator = peek(generator) :: Types.CurveGenerator<V>

		if castToState(generator) then
			depend(self, generator :: any)
		end

		depend(self, timer)
		depend(self, goal)

		-- wake
		if
			nextGoal ~= self._activeGoal :: any
			or nextGenerator ~= self._activeGenerator
		then
			self._activeStart = self._internalValue
			self._activeGoal = nextGoal

			self._activeGenerator = nextGenerator
			self._activeCurve = nextGenerator(self._activeStart, self._activeGoal)

			timer:reset()
			timer:unpause()
		end

		local elapsed = peek(timer) :: number

		if elapsed == 0 then
			elapsed = External.getDeltaTime()
		end

		local shouldSleep, newValue = self._activeCurve(elapsed)
		-- sleep

		if shouldSleep or (self._activeStart :: any) == nextGoal then
			timer:pause()
		end

		local oldValue = self._internalValue :: any

		self._internalValue = newValue

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

		_timer = timer,
	}, METATABLE) :: any

	evaluate(newAnimated, true)

	return newAnimated
end

return Animated
