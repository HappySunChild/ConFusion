--!strict
local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local change = require(package.Graph.change)
local observe = require(package.Graph.observe)

type Clock = Types.StateObject<number> & {
	type: "clock",
}

local Clock = {
	kind = "state",
	type = "clock",
	scope = {},
	_createdAt = os.clock(),
	_internalValue = os.clock(),
	_users = {},
	_using = table.freeze {},
} :: Clock

function Clock.onChange(self: Clock, callback)
	return observe(self, callback)
end

function Clock._evaluate()
	return true
end

External.bindToUpdate(function(now)
	Clock._internalValue = now

	change(Clock)
end)

return Clock
