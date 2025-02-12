local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local change = require(package.State.change)
local depend = require(package.Graph.depend)
local peek = require(package.State.peek)

local Clock = require(package.Utility.Clock)

local Start = Symbols.named('Start')
local Paused = Symbols.named('Paused')

local StopwatchClass = {
	[Symbols.Kind] = Kinds.State,
	[Symbols.Type] = Types.Stopwatch,
}

local METATABLE = table.freeze({ __index = StopwatchClass })

local function createStopwatch()
	local newStopwatch = setmetatable({
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.Internal] = 0,

		[Symbols.Users] = {},
		[Symbols.Using] = {},

		[Start] = peek(Clock),
		[Paused] = true,
	}, METATABLE)

	depend(newStopwatch, Clock)

	return newStopwatch
end

function StopwatchClass:reset()
	local now = peek(Clock)

	if now == self[Start] then
		return
	end

	self[Start] = peek(Clock)
	self[Symbols.Internal] = 0

	change(self)
end

function StopwatchClass:pause()
	if self[Paused] then
		return
	end

	self[Paused] = true

	change(self)
end

function StopwatchClass:unpause()
	if not self[Paused] then
		return
	end

	self[Paused] = false
	self[Start] = peek(Clock) - self[Symbols.Internal]

	change(self)
end

function StopwatchClass:_evaluate()
	if self[Paused] then
		return false
	end

	depend(self, Clock)

	local currentTime = peek(Clock)
	local oldValue = self[Symbols.Internal]
	local newValue = currentTime - self[Start]

	self[Symbols.Internal] = newValue

	return newValue ~= oldValue
end

table.freeze(StopwatchClass)

return createStopwatch
