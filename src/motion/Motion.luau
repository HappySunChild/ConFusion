local calc = require "../core-calc/types"
local chrono = require "../chrono/types"
local memory = require "../core-memory/types"
local motion = require "./types"

local External = require "../core-external/External"

local castToState = require "../core-calc/castToState"
local isSimilar = require "../core-calc/isSimilar"

local change = require "../core-graph/change"
local depend = require "../core-graph/depend"
local evaluate = require "../core-graph/evaluate"

local destructor = require "../core-memory/destructor"

local peek = require "../core-use/peek"

local Timer = require "../chrono/Timer"

type Self<T> = motion.Motion<T> & {
	_goal: calc.UsedAs<T>,
	_generator: calc.UsedAs<motion.MoveGenerator<T>>,

	_dynamics: { any },

	_regenerate: boolean?,

	_active_goal: T,
	_active_generator: motion.MoveGenerator<T>,
	_active_move: motion.AnimationMove<T>,

	_timer: chrono.Timer,

	_syncDynamics: (Self<T>, should_sleep: boolean, output: T, ...any) -> (T, boolean),
	_wake: (Self<T>) -> (),
	_sleep: (Self<T>) -> (),
}

local CLASS = table.freeze {
	type = "State",
	kind = "Motion",
	timeliness = "eager",

	setDynamic = function<T>(self: Self<T>, index: number, value: any)
		self._active_dynamics[index] = value
		self._regenerate = true

		change(self)
	end,
	getDynamic = function<T>(self: Self<T>, index: number)
		return self._active_dynamics[index]
	end,

	_syncDynamics = function<T>(
		self: Self<T>,
		should_sleep: boolean,
		output: T,
		...: any
	): (T, boolean)
		local dynamics = self._dynamics

		table.clear(self._dynamics)

		if output ~= output then
			External.logWarn(motion.animated_invalid_motion, output, self._active_goal)

			output = self._active_goal
		end

		dynamics[1] = output

		for i = 1, select("#", ...) do
			dynamics[i + 1] = select(i, ...)
		end

		return output, should_sleep
	end,
	_wake = function<T>(self: Self<T>)
		self._regenerate = nil

		local timer = self._timer
		local goal = peek(self._goal)
		local generator = peek(self._generator)

		self._active_goal = goal
		self._active_generator = generator
		self._active_move = generator(goal, unpack(self._dynamics))

		timer:zero()
		timer:unpause()
	end,
	_sleep = function<T>(self: Self<T>)
		local timer = self._timer

		timer:pause()
	end,
	_evaluate = function<T>(self: Self<T>)
		local timer = self._timer
		local goal = self._goal
		local generator = self._generator

		local next_goal = peek(goal) :: T

		depend(self, castToState(goal))

		-- protect against NaN goals
		if next_goal ~= next_goal then
			External.logWarn(motion.animated_invalid_goal, next_goal)

			return false
		end

		local next_generator = peek(generator) :: motion.MoveGenerator<T>

		depend(self, castToState(generator))
		depend(self, timer)

		-- wake
		if
			next_goal ~= self._active_goal
			or next_generator ~= self._active_generator
			or self._regenerate == true
		then
			self:_wake()
		end

		local elapsed = peek(timer) :: number

		-- fix Motions following eachother
		if elapsed == 0 then
			elapsed = External.getDeltaTime()
		end

		local old_value = self._internal_value :: any
		local new_value, should_sleep = self:_syncDynamics(self._active_move(elapsed))

		self._internal_value = new_value

		if should_sleep then
			self:_sleep()
		end

		return isSimilar(old_value, new_value)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function Motion<T>(
	scope: memory.Scope,
	goal: calc.UsedAs<T>,
	mover: calc.UsedAs<motion.MoveGenerator<T>>
): motion.Motion<T>
	local new_motion: Self<T> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_internal_value = nil,

		_using = {},
		_users = {},

		_goal = goal,
		_generator = mover,

		_dynamics = {},

		_active_goal = nil,
		_active_generator = nil,
		_active_curve = nil,

		_timer = Timer(scope),
	}, METATABLE) :: any

	table.insert(scope, destructor(new_motion))

	evaluate(new_motion, true)

	return new_motion
end

return Motion
