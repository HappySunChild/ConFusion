local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local change = require(package.State.change)
local depend = require(package.Graph.depend)
local destructor = require(package.Memory.destructor)
local peek = require(package.State.peek)

local Clock = require(package.Utility.Clock)

local Start = Symbols.named 'Start'
local Paused = Symbols.named 'Paused'

export type Stopwatch = Types.StateObject<number> & {
	reset: (Stopwatch) -> (),
	pause: (Stopwatch) -> (),
	unpause: (Stopwatch) -> (),
}

local StopwatchClass = {
	[Symbols.Kind] = Kinds.State,
	[Symbols.Type] = Types.Stopwatch,
}

local METATABLE = table.freeze { __index = StopwatchClass }

local function Stopwatch(scope: Types.Scope): Stopwatch
	local newStopwatch = setmetatable({
		[Symbols.Scope] = scope,
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.InternalValue] = 0,

		[Symbols.Users] = {},
		[Symbols.Using] = {},

		[Start] = peek(Clock),
		[Paused] = true,
	}, METATABLE)

	table.insert(scope, destructor(newStopwatch))

	depend(newStopwatch, Clock)

	return newStopwatch
end

function StopwatchClass:reset()
	self = self :: Stopwatch

	local now = peek(Clock)

	if now == self[Start] then
		return
	end

	self[Start] = peek(Clock)
	self[Symbols.InternalValue] = 0

	change(self)
end

function StopwatchClass:pause()
	self = self :: Stopwatch

	if self[Paused] then
		return
	end

	self[Paused] = true

	change(self)
end

function StopwatchClass:unpause()
	self = self :: Stopwatch

	if not self[Paused] then
		return
	end

	self[Paused] = false
	self[Start] = peek(Clock) - self[Symbols.InternalValue]

	change(self)
end

function StopwatchClass:_evaluate()
	self = self :: Stopwatch

	if self[Paused] then
		return false
	end

	depend(self, Clock)

	local currentTime = peek(Clock)
	local oldValue = self[Symbols.InternalValue]
	local newValue = currentTime - self[Start]

	self[Symbols.InternalValue] = newValue

	return newValue ~= oldValue
end

table.freeze(StopwatchClass)

return Stopwatch
