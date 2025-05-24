local External = require "../External"
local Types = require "../Types"

local castToGraph = require "./castToGraph"
local depend = require "./depend"

type Self = Types.Observer & {
	_subject: Types.GraphObject?,
	_listeners: { () -> () },
}

local class = {
	type = "observer",
	kind = "graph",
	timeliness = "eager",
	_using = table.freeze {},
}
local METATABLE = table.freeze { __index = class }

local function Observer(scope: Types.Scope, subject: Types.GraphObject)
	local newObserver = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},
		_listeners = {},
		_subject = subject,
	}, METATABLE)

	return newObserver
end

function class.onBind(self: Self, callback: () -> ())
	External.doTaskImmediate(callback)
	return self:onChange(callback)
end

function class.onChange(self: Self, callback: () -> ())
	local uniqueId = table.freeze {}

	self._listeners[uniqueId] = callback

	return function()
		self._listeners[uniqueId] = nil
	end
end

function class._evaluate(self: Self)
	if not castToGraph(self._subject) then
		return
	end

	depend(self, self._subject)

	for _, callback in self._listeners do
		External.doTaskImmediate(callback)
	end

	return true
end

return Observer
