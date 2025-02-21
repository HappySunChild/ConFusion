--!strict

local class = {
	type = "signal",
}

local METATABLE = table.freeze { __index = class }

local function Signal()
	local newSignal = setmetatable({
		_subscriptions = {},
	}, METATABLE)

	return newSignal
end

function class:fire(...)
	for _, callback in self._subscriptions do
		callback(...)
	end
end

function class:connect(callback)
	local uniqueIdentifier = {}

	self._subscriptions[uniqueIdentifier] = callback

	return function()
		self._subscriptions[uniqueIdentifier] = callback
	end
end

return Signal
