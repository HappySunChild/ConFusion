local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local depend = require(package.Graph.depend)
local evaluate = require(package.Graph.evaluate)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local deriveScope = require(package.Memory.deriveScope)
local destructor = require(package.Memory.destructor)
local doCleanup = require(package.Memory.doCleanup)

local isSimilar = require(package.Utility.isSimilar)

local parseError = require(package.Logging.parseError)

type Self<S, V> = Types.Computed<V> & {
	_innerScope: Types.Scope<S>?,
	_processor: (use: Types.Use, scope: Types.Scope<S>) -> V,
}

local class = {
	kind = "state",
	type = "computed",
}

local METATABLE = table.freeze { __index = class }

local function Computed<S, VO>(
	scope: Types.Scope,
	processor: (Types.Use, Types.Scope<S>) -> VO
): Types.Computed<VO>
	local newComputed = setmetatable({
		scope = scope,
		_createdAt = os.clock(),
		_internalValue = nil,

		_using = {},
		_users = {},

		_processor = processor,
	}, METATABLE)

	table.insert(scope, destructor(newComputed))

	evaluate(newComputed, true)

	return newComputed
end

function class._evaluate<V>(self: Self<V>)
	if self.scope == nil then
		return false
	end

	local outerScope = self.scope
	local innerScope = deriveScope(outerScope)

	local function use(target)
		if castToState(target) then
			depend(self, target)
		end

		return peek(target)
	end

	local success, newValue = xpcall(self._processor, parseError, use, innerScope)

	if success then
		local oldValue = self._internalValue

		if self._innerScope ~= nil then
			doCleanup(self._innerScope)
			self._innerScope = nil
		end

		self._innerScope = innerScope

		self._internalValue = newValue

		return not isSimilar(newValue, oldValue)
	else
		doCleanup(self._innerScope)

		External.logErrorNonFatal("callbackError", newValue)
	end

	return false
end

table.freeze(class)

return Computed
