local External = require "../External"
local Types = require "../Types"

local castToGraph = require "./castToGraph"
local depend = require "./depend"
local evaluate = require "./evaluate"

local destructor = require "../Memory/destructor"

type Self = Types.Observer & {
	_subjects: { Types.GraphObject },
	_listeners: { () -> () },
}

local class = {
	type = "Observer",
	kind = "graph",
	timeliness = "eager",
	_users = table.freeze {},
}
local METATABLE = table.freeze { __index = class }

local function Observer(scope: Types.Scope, ...: Types.GraphObject)
	local newObserver = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_using = {},
		
		_listeners = {},
		_subjects = { ... },
	}, METATABLE)

	table.insert(scope, destructor(newObserver))

	evaluate(newObserver)

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
	for _, subject in self._subjects do
		if castToGraph(subject) then
			depend(self, subject)
		end
	end

	for _, callback in self._listeners do
		-- it'd be nice if we could pass which subject was the one that changed,
		-- but i don't think that's currently possible without having to do some major changes to how the graph works.
		-- maybe it could be passed into _evaluate? again i'm not sure how this'd work.
		External.doTaskImmediate(callback, unpack(self._subjects))
	end

	return true
end

return Observer
