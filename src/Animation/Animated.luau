local package = script.Parent.Parent

local Types = require(package.Types)

local Timer = require(package.Animation.Timer)

local depend = require(package.Graph.depend)
local evaluate = require(package.Graph.evaluate)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

type Self<V> = Types.StateObject<V> & {
	_goal: Types.UsedAs<V>,
	_activeStart: V?,
	_activeFinish: V?,

	_mover: (V) -> (),
	_activeMover: ((elapsed: number) -> V)?,

	_timer: Timer.Timer,
}

local class = {
	kind = "state",
	type = "animated",
}

local METATABLE = table.freeze { __index = class }

local function Animated<V>(scope: Types.Scope, goal: Types.UsedAs<V>, mover: () -> ())
	local timer = Timer(scope)
	local newAnimated = setmetatable({
		scope = scope,
		_createdAt = os.clock(),
		_internalValue = peek(goal),

		_using = {},
		_users = {},

		_goal = goal,
		_activeStart = nil,
		_activeFinish = nil,

		_mover = mover,
		_activeMover = nil,

		_timer = timer,
	}, METATABLE)

	evaluate(newAnimated, true)

	return newAnimated
end

function class._evaluate<V>(self: Self<V>)
	local goal = self._goal

	if not castToState(self._goal) then
		return false
	end

	depend(self, goal)

	local timer = self._timer
	local finish = peek(goal)

	depend(self, timer)

	if finish ~= self._activeFinish then
		self._activeStart = self._internalValue
		self._activeFinish = finish
		self._activeMover = self._mover(self._activeStart, self._activeFinish)

		timer:reset()
		timer:unpause()
	end

	local mover = self._activeMover
	local elapsed = peek(timer)

	local shouldSleep, newValue = mover(elapsed)

	if shouldSleep or self._activeStart == finish then
		timer:pause()
	end

	local oldValue = self._internalValue :: any

	self._internalValue = newValue

	return oldValue ~= newValue
end

return Animated
