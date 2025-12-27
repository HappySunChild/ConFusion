local chrono = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local change = require "../core-graph/change"

local generic_destroy = require "../core-memory/generic_destroy"

type Self = chrono.ExternalTime

local ALL_TIMERS = {}

local CLASS = {
	type = "State",
	kind = "ExternalTime",
	timeliness = "lazy",
	_using = table.freeze {},
	_internal_value = External.get_last_update(),

	enabled = function(self: Self)
		ALL_TIMERS[self] = true
	end,
	disable = function(self: Self)
		ALL_TIMERS[self] = nil
	end,
	is_enabled = function(self: Self)
		return ALL_TIMERS[self] ~= nil
	end,

	_evaluate = function(self: Self)
		return true
	end,
	destroy = function(self: Self)
		ALL_TIMERS[self] = nil

		generic_destroy(self)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function ExternalTime(scope: memory.Scope): chrono.ExternalTime
	local new_externaltime = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_users = {},
	}, METATABLE) :: Self

	new_externaltime[new_externaltime] = true

	table.insert(scope, new_externaltime)

	return new_externaltime
end

External.bind_to_update_step(function(now: number)
	CLASS._internal_value = now

	for timer in ALL_TIMERS do
		change(timer)
	end
end)

return ExternalTime
