--!strict

local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Subscriptions = Symbols.named 'Subscriptions'

local class = {
	type = 'signal',
}

local METATABLE = table.freeze { __index = class }

local function Signal()
	local newSignal = setmetatable({
		[Subscriptions] = {},
	}, METATABLE)

	return newSignal
end

function class:fire(...)
	for _, callback in self[Subscriptions] do
		callback(...)
	end
end

function class:connect(callback)
	local uniqueIdentifier = {}

	self[Subscriptions][uniqueIdentifier] = callback

	return function()
		self[Subscriptions][uniqueIdentifier] = callback
	end
end

return Signal
