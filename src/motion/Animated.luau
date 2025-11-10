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
	_generator: calc.UsedAs<motion.CurveGenerator<T>>,

	_regenerate: boolean?,

	_active_goal: T,
	_active_dynamics: { any },

	_active_generator: motion.CurveGenerator<T>,
	_active_curve: motion.AnimationCurve<T>,

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
	type = "State",
	kind = "Animated",
	timeliness = "eager",

	setDynamic = function<T>(self: Self<T>, index: number, value: any)
		self._active_dynamics[index] = value
		self._regenerate = true

		change(self)
	end,
	getDynamic = function<T>(self: Self<T>, index: number)
		return self._active_dynamics[index]
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
			External.logWarn(motion.animated_invalid_goal, next_goal)

			return false
		end

		local next_generator = peek(generator) :: motion.CurveGenerator<T>

		if castToState(generator) ~= nil then
			depend(self, generator :: any)
		end

		depend(self, timer)

		-- wake
		if
			next_goal ~= self._active_goal :: any
			or next_generator ~= self._active_generator
			or self._regenerate == true
		then
			self._regenerate = nil

			self._active_goal = next_goal

			self._active_generator = next_generator
			self._active_curve =
				next_generator(self._active_goal, unpack(self._active_dynamics))

			timer:zero()
			timer:unpause()
		end

		local elapsed = peek(timer) :: number

		-- fix Animateds following eachother
		if elapsed == 0 then
			elapsed = External.getDeltaTime()
		end

		local old_value = self._internal_value :: any
		local new_value, should_sleep =
			syncFromCurve(self._active_dynamics, self._active_curve(elapsed))

		if (new_value :: any) ~= (new_value :: any) then
			External.logWarn(motion.animated_invalid_motion, new_value, self._active_goal)

			new_value = self._active_goal
		end

		self._active_dynamics[1] = new_value
		self._internal_value = new_value

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
		created_at = os.clock(),

		_internal_value = nil,

		_using = {},
		_users = {},

		_goal = goal,
		_active_goal = nil,

		_active_dynamics = { peek(goal) },

		_generator = mover,
		_active_generator = nil,
		_active_curve = nil,

		_timer = Timer(scope),
	}, METATABLE) :: any

	table.insert(scope, destructor(new_animated))

	evaluate(new_animated, true)

	return new_animated
end

return Animated
