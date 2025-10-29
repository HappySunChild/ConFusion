local calc = require "../core-calc/types"
local chrono = require "../chrono/types"
local memory = require "../core-memory/types"
local motion = require "./types"

local External = require "../core-external/External"
local Timer = require "../chrono/Timer"
local castToState = require "../core-calc/castToState"
local change = require "../core-graph/change"
local depend = require "../core-graph/depend"
local destructor = require "../core-memory/destructor"
local evaluate = require "../core-graph/evaluate"
local peek = require "../core-use/peek"

type Self<T> = motion.Animated<T> & {
	_goal: calc.UsedAs<T>,
	_activeGoal: T,

	_activeDynamics: { any },
	_regenerate: boolean?,

	_generator: calc.UsedAs<motion.CurveGenerator<T>>,
	_activeGenerator: motion.CurveGenerator<T>,
	_activeCurve: motion.AnimationCurve<T>,

	_timer: chrono.Timer,
}

local function syncFromCurve<T>(
	dynamics: { any },
	should_sleep: boolean,
	output: T,
	...: any
): (T, boolean)
	table.clear(dynamics)

	for i = 1, select("#", ...) do
		dynamics[i + 1] = select(i, ...)
	end

	return output, should_sleep
end

local CLASS = table.freeze {
	type = "Animated",
	kind = "state",
	timeliness = "eager",

	setDynamic = function<T>(self: Self<T>, index: number, value: any)
		self._activeDynamics[index] = value
		self._regenerate = true

		change(self)
	end,
	getDynamic = function<T>(self: Self<T>, index: number)
		return self._activeDynamics[index]
	end,
	_evaluate = function<T>(self: Self<T>)
		local goal = self._goal

		local generator = self._generator
		local timer = self._timer

		local next_goal = peek(goal)

		if castToState(goal) ~= nil then
			depend(self, goal)
		end

		-- protect against NaN goals
		if next_goal ~= next_goal then
			External.logWarn(motion.animatedInvalidGoal, next_goal)

			return false
		end

		local next_generator = peek(generator) :: motion.CurveGenerator<T>

		if castToState(generator) ~= nil then
			depend(self, generator :: any)
		end

		depend(self, timer)

		-- wake
		if
			next_goal ~= self._activeGoal :: any
			or next_generator ~= self._activeGenerator
			or self._regenerate == true
		then
			self._regenerate = nil

			self._activeGoal = next_goal

			self._activeGenerator = next_generator
			self._activeCurve =
				next_generator(self._activeGoal, unpack(self._activeDynamics))

			timer:reset()
			timer:unpause()
		end

		local elapsed = peek(timer) :: number

		-- fix Animateds following eachother
		if elapsed == 0 then
			elapsed = External.getDeltaTime()
		end

		local old_value = self._internalValue :: any
		local new_value, should_sleep =
			syncFromCurve(self._activeDynamics, self._activeCurve(elapsed))

		if (new_value :: any) ~= (new_value :: any) then
			External.logWarn(motion.animatedInvalidMotion, new_value, self._activeGoal)

			new_value = self._activeGoal
		end

		self._activeDynamics[1] = new_value
		self._internalValue = new_value

		if should_sleep then
			timer:pause()
		end

		return (old_value :: any) ~= (new_value :: any)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function Animated<T>(
	scope: memory.Scope,
	goal: calc.UsedAs<T>,
	mover: calc.UsedAs<motion.CurveGenerator<T>>
): motion.Animated<T>
	local new_animated: Self<T> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_internalValue = nil,

		_using = {},
		_users = {},

		_goal = goal,
		_activeGoal = nil,

		_activeDynamics = { peek(goal) },

		_generator = mover,
		_activeGenerator = nil,
		_activeCurve = nil,

		_timer = Timer(scope),
	}, METATABLE) :: any

	table.insert(scope, destructor(new_animated))

	evaluate(new_animated, true)

	return new_animated
end

return Animated
