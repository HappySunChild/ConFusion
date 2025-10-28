local chrono = require "./types"
local memory = require "../core-memory/types"

local peek = require "../core-use/peek"

local change = require "../core-graph/change"
local depend = require "../core-graph/depend"

local destructor = require "../core-memory/destructor"

local ExternalTime = require "./ExternalTime"

type Self = chrono.Timer & {
	_paused: boolean,
	_start: number,
	_timer: chrono.ExternalTime,
}

local class = table.freeze {
	type = "Timer",
	kind = "state",
	timeliness = "lazy",

	unpause = function(self: Self)
		if not self._paused then
			return
		end

		self._timer:setActive(true)
		self._paused = false

		change(self)
	end,
	pause = function(self: Self)
		if self._paused then
			return
		end

		self._timer:setActive(false)
		self._paused = true

		change(self)
	end,
	reset = function(self: Self)
		self._start = peek(self._timer) :: number
		self._internalValue = 0

		change(self)
	end,
	_evaluate = function(self: Self)
		if self._paused then
			return false
		end

		depend(self, self._timer)

		local now = peek(self._timer) :: number

		local old_value = self._internalValue
		local new_value = now - self._start

		self._internalValue = new_value

		return old_value ~= new_value
	end,
}
local METATABLE = table.freeze { __index = class }

local function Timer(scope: memory.Scope): chrono.Timer
	local externaltime = ExternalTime(scope)

	local newTimer = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = 0,

		_paused = false,
		_start = peek(externaltime),

		_using = {},
		_users = {},
		_timer = externaltime,
	}, METATABLE) :: Self

	table.insert(scope, destructor(newTimer))

	depend(newTimer, externaltime)

	return newTimer
end

return Timer
