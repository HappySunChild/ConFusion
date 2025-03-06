local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local destructor = require(package.Memory.destructor)

local depend = require(package.Graph.depend)
local evaluate = require(package.Graph.evaluate)

type Self = Types.Observer & {
	_watching: Types.GraphObject,
	_listeners: { [() -> ()]: true },
}

local class = {
	type = "observer",
	kind = "graph",
	timeliness = "eager",
	_users = table.freeze {},
}

local METATABLE = table.freeze { __index = class }

local function Observer(scope: Types.Scope, target: Types.GraphObject): Types.Observer
	local newObserver = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_using = {},

		_listeners = {},
		_watching = target,
	}, METATABLE)

	table.insert(scope, destructor(newObserver))

	evaluate(newObserver, true)

	return newObserver
end

function class.onBind(self: Self, callback)
	External.doTaskImmediate(callback)

	return self:onUpdate(callback)
end

function class.onUpdate(self: Self, callback)
	self._listeners[callback] = true

	return function()
		self._listeners[callback] = nil
	end
end

function class._evaluate(self: Self)
	depend(self, self._watching)

	for callback in self._listeners do
		External.doTaskImmediate(callback)
	end

	return true
end

return Observer
