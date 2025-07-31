--!strict
local calc = require "../calc/types"
local chrono = require "../chrono/types"
local memory = require "../memory/types"
local motion = require "./types"

local External = require "../External"

local Timer = require "../chrono/Timer"

local depend = require "../graph/depend"
local evaluate = require "../graph/evaluate"

local destructor = require "../memory/destructor"

local castToState = require "../calc/castToState"

local peek = require "../use/peek"

type Self<V> = motion.Animated<V> & {
	_goal: calc.UsedAs<V>,
	_activeStart: V,
	_activeGoal: V,

	_generator: calc.UsedAs<motion.CurveGenerator<V>>,
	_activeGenerator: motion.CurveGenerator<V>,
	_activeCurve: motion.AnimationCurve<V>,

	_timer: chrono.Timer,
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
		local nextGenerator = peek(generator) :: motion.CurveGenerator<V>

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
	scope: memory.Scope,
	goal: calc.UsedAs<V>,
	mover: calc.UsedAs<motion.CurveGenerator<V>>
): motion.Animated<V>
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

	table.insert(scope, destructor(newAnimated))

	evaluate(newAnimated, true)

	return newAnimated
end

return Animated
