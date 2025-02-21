local package = script.Parent.Parent

local Types = require(package.Types)

local Stopwatch = require(package.Animation.Stopwatch)
local getTweenAlpha = require(package.Animation.getTweenAlpha)
local getTweenDuration = require(package.Animation.getTweenDuration)
local lerp = require(package.Animation.lerp)

local depend = require(package.Graph.depend)
local evaluate = require(package.Graph.evaluate)
local observe = require(package.Graph.observe)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local destructor = require(package.Memory.destructor)

type Self<V> = Types.Tween<V> & {
	_info: Types.UsedAs<TweenInfo>,
	_goal: Types.UsedAs<V>,
	_timer: Stopwatch.Stopwatch,

	_tweenStart: unknown,
	_tweenFinish: unknown,
	_tweenDuration: number,
	_elapsed: number,
}

local class = {
	type = "tween",
	kind = "state",
}

local METATABLE = table.freeze { __index = class }

local function Tween<V>(
	scope: Types.Scope,
	goal: Types.UsedAs<V>,
	info: Types.UsedAs<TweenInfo>
): Types.Tween<V>
	local newTween = setmetatable({
		scope = scope,
		_createdAt = os.clock(),
		_internalValue = peek(goal),

		_using = {},
		_users = {},

		_info = info,
		_goal = goal,
		_timer = Stopwatch(scope),

		_tweenStart = nil,
		_tweenFinish = nil,
		_tweenDuration = nil,

		_elapsed = 0,
	}, METATABLE) :: Self<V>

	table.insert(scope, destructor(newTween))

	evaluate(newTween, true)

	return newTween
end

function class.onChange<V>(self: Self<V>, callback)
	return observe(self, callback)
end

function class._evaluate<V>(self: Self<V>)
	local goal = self._goal

	if not castToState(goal) then
		self._internalValue = goal

		return false
	end

	depend(self, goal)

	local finish = peek(goal)
	local info = peek(self._info)

	local stopwatch = self._timer

	if finish ~= self._tweenFinish then
		self._tweenDuration = getTweenDuration(info) :: number
		self._tweenStart = self._internalValue
		self._tweenFinish = finish

		stopwatch:reset()
		stopwatch:unpause()
	end

	depend(self, stopwatch)

	self._elapsed = peek(stopwatch) :: number

	if self._tweenStart == self._tweenFinish or self._elapsed > self._tweenDuration then
		self._tweenStart = self._tweenFinish
		self._elapsed = self._tweenDuration

		stopwatch:pause()
	end

	local alpha = getTweenAlpha(info, self._elapsed)
	local oldValue = self._internalValue :: unknown
	local newValue = lerp(self._tweenStart, self._tweenFinish, alpha) :: unknown

	self._internalValue = newValue

	return newValue ~= oldValue
end

table.freeze(class)

return Tween
