local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local change = require(package.Graph.change)
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

local class = {
	kind = 'state',
	type = 'stopwatch',
}

local METATABLE = table.freeze { __index = class }

local function Stopwatch(scope: Types.Scope): Stopwatch
	local newStopwatch = setmetatable({
		[Symbols.Scope] = scope,
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.InternalValue] = 0,

		[Symbols.Users] = {},
		[Symbols.Using] = {},

		[Start] = peek(Clock),
		[Paused] = true,
	}, METATABLE) :: Stopwatch

	table.insert(scope, destructor(newStopwatch))

	depend(newStopwatch, Clock)

	return newStopwatch :: Stopwatch
end

function class:reset()
	local now = peek(Clock)

	if now == self[Start] then
		return
	end

	self[Start] = peek(Clock)
	self[Symbols.InternalValue] = 0

	change(self)
end

function class:pause()
	if self[Paused] then
		return
	end

	self[Paused] = true

	change(self)
end

function class:unpause()
	if not self[Paused] then
		return
	end

	self[Paused] = false
	self[Start] = peek(Clock) - self[Symbols.InternalValue]

	change(self)
end

function class:_evaluate()
	if self[Paused] then
		return false
	end

	depend(self :: Stopwatch, Clock)

	local currentTime = peek(Clock)
	local oldValue = self[Symbols.InternalValue]
	local newValue = currentTime - self[Start]

	self[Symbols.InternalValue] = newValue

	return newValue ~= oldValue
end

table.freeze(class)

return Stopwatch
