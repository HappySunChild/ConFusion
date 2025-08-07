--!strict
local chrono = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local change = require "../graph/change"

local destructor = require "../memory/destructor"

type Self = chrono.ExternalTime & {
	_active: boolean,
}

local class = {
	type = "ExternalTime",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},
	_internalValue = External.getLastUpdate(),

	setActive = function(self: Self, active: boolean)
		self._active = active
	end,
	isActive = function(self: Self)
		return self._active
	end,
	_evaluate = function(self: Self)
		return true
	end,
}

local METATABLE = table.freeze { __index = class }

local allTimers = {}

local function ExternalTime(scope: memory.Scope): chrono.ExternalTime
	local newExternalTime = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},
		_active = true,
	}, METATABLE) :: Self

	table.insert(scope, {
		destructor(newExternalTime),
		function()
			local index = table.find(allTimers, newExternalTime)

			if index ~= nil then
				table.remove(allTimers, index)
			end
		end,
	})
	table.insert(allTimers, newExternalTime)

	return newExternalTime
end

External.bindToUpdate(function(now: number)
	class._internalValue = now

	for _, timer in allTimers do
		if timer:isActive() then
			change(timer)
		end
	end
end)

return ExternalTime
