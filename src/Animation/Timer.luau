local Types = require "../Types"

local peek = require "../State/peek"

local change = require "../Graph/change"
local depend = require "../Graph/depend"

local destructor = require "../Memory/destructor"

local ExternalTime = require "./ExternalTime"

type Self = Types.Timer & {
	_start: number,
	_timer: ExternalTime.ExternalTime,
}

local class = table.freeze {
	type = "Timer",
	kind = "state",
	timeliness = "lazy",

	unpause = function(self: Self)
		if not self.isPaused then
			return
		end

		self._timer:setActive(true)
		self.isPaused = false

		change(self)
	end,
	pause = function(self: Self)
		if self.isPaused then
			return
		end

		self._timer:setActive(false)
		self.isPaused = true

		change(self)
	end,
	reset = function(self: Self)
		self._start = peek(self._timer) :: number
		self._internalValue = 0

		change(self)
	end,
	_evaluate = function(self: Self)
		if self.isPaused then
			return false
		end

		depend(self, self._timer)

		local now = peek(self._timer) :: number

		local oldValue = self._internalValue
		local newValue = now - self._start

		self._internalValue = newValue

		return oldValue ~= newValue
	end,
}
local METATABLE = table.freeze { __index = class }

local function Timer(scope: Types.Scope): Types.Timer
	local externalTime = ExternalTime(scope)

	local newTimer = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = 0,

		isPaused = false,
		_start = peek(externalTime),

		_using = {},
		_users = {},
		_timer = externalTime,
	}, METATABLE) :: Self

	table.insert(scope, destructor(newTimer))

	depend(newTimer, externalTime)

	return newTimer
end

return Timer
