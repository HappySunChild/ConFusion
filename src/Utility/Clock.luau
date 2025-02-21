--!strict
local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local Computed = require(package.State.Computed)

local change = require(package.Graph.change)
local observe = require(package.Graph.observe)

local destructor = require(package.Memory.destructor)

type Clock = Types.StateObject<number> & {
	type: "clock",
}

local class = {
	kind = "state",
	type = "clock",
	_using = table.freeze {},
}

local METATABLE = table.freeze { __index = class }

local function Clock(scope: Types.Scope)
	local newClock = setmetatable({
		scope = {},
		_createdAt = os.clock(),
		_internalValue = os.clock(),

		_users = {},
	}, METATABLE) :: Clock

	local unbind = External.bindToUpdate(function(now)
		class._internalValue = now

		change(newClock)
	end)

	table.insert(scope, { unbind, destructor(newClock) })

	return newClock
end

function class.map(self: Clock, callback: (number) -> unknown)
	return Computed(self.scope, function(use)
		return callback(use(self))
	end)
end

function class.onChange(self: Clock, callback)
	return observe(self, callback)
end

function class._evaluate()
	return true
end

return Clock
