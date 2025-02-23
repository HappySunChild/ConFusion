local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local Timer = require(package.Animation.Timer)

local depend = require(package.Graph.depend)
local evaluate = require(package.Graph.evaluate)
local observe = require(package.Graph.observe)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

type Self<V> = Types.Animated<V> & {
	_goal: Types.UsedAs<V>,
	_activeStart: V?,
	_activeFinish: V?,

	_mover: (V) -> (),
	_activeMover: ((elapsed: number) -> V)?,

	_timer: Timer.Timer,
	_statusListeners: { [{}]: (boolean) -> () },
}

local class = {
	kind = "state",
	type = "animated",
}

local METATABLE = table.freeze { __index = class }

local function Animated<V>(
	scope: Types.Scope,
	goal: Types.UsedAs<V>,
	mover: () -> ()
): Types.Animated<V>
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
		_statusListeners = {},

		status = false,
	}, METATABLE)

	evaluate(newAnimated, true)

	return newAnimated
end

function class.onChange<V>(self: Self<V>, callback: (V) -> ())
	return observe(self, callback)
end

function class.bindStatusChange<V>(self: Self<V>, callback: (boolean) -> ())
	local uniqueIdentifier = {}

	self._statusListeners[uniqueIdentifier] = callback

	return function()
		self._statusListeners[uniqueIdentifier] = nil
	end
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

		if not self.status then
			self.status = true

			for _, callback in self._statusListeners do
				External.doTaskImmediate(callback, true)
			end
		end
	end

	local mover = self._activeMover
	local elapsed = peek(timer)

	local shouldSleep, newValue = mover(elapsed)

	if shouldSleep or self._activeStart == finish then
		timer:pause()

		if self.status then
			self.status = false

			for _, callback in self._statusListeners do
				External.doTaskImmediate(callback, false)
			end
		end
	end

	local oldValue = self._internalValue :: any

	self._internalValue = newValue

	return oldValue ~= newValue
end

return Animated
