local package = script.Parent.Parent

local Types = require(package.Types)

local Clock = require(package.Utility.Clock)

local change = require(package.Graph.change)
local depend = require(package.Graph.depend)
local observe = require(package.Graph.observe)

local destructor = require(package.Memory.destructor)

local peek = require(package.State.peek)

export type Stopwatch = Types.StateObject<number> & {
	type: "stopwatch",

	reset: (Stopwatch) -> (),
	pause: (Stopwatch) -> (),
	unpause: (Stopwatch) -> (),
}

type Self = Stopwatch & {
	_timer: Types.StateObject<number>,
	_paused: boolean,
	_start: number,
}

local class = {
	kind = "state",
	type = "stopwatch",
}

local METATABLE = table.freeze { __index = class }

local function Stopwatch(scope: Types.Scope): Stopwatch
	local timer = Clock(scope)
	local newStopwatch = setmetatable({
		scope = scope,
		_createdAt = os.clock(),
		_internalValue = 0,

		_users = {},
		_using = {},

		_timer = timer,
		_start = peek(Clock),
		_paused = true,
	}, METATABLE) :: Self

	table.insert(scope, destructor(newStopwatch))

	depend(newStopwatch, timer)

	return newStopwatch
end

function class.onChange(self: Self, callback)
	return observe(self, callback)
end

function class.reset(self: Self)
	local now = peek(self._timer)

	if now == self._start then
		return
	end

	self._start = peek(self._timer) :: number
	self._internalValue = 0

	change(self)
end

function class.pause(self: Self)
	if self._paused then
		return
	end

	self._paused = true

	change(self)
end

function class.unpause(self: Self)
	if not self._paused then
		return
	end

	self._paused = false
	self._start = (peek(self._timer) :: number) - self._internalValue

	change(self)
end

function class._evaluate(self: Self)
	if self._paused then
		return false
	end

	depend(self, self._timer)

	local currentTime = peek(self._timer) :: number
	local oldValue = self._internalValue :: number
	local newValue = (currentTime - self._start) :: number

	self._internalValue = newValue

	return newValue ~= oldValue
end

table.freeze(class)

return Stopwatch
