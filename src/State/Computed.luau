local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local depend = require(package.Graph.depend)
local evaluate = require(package.Graph.evaluate)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local destructor = require(package.Memory.destructor)

local isSimilar = require(package.Utility.isSimilar)

local parseError = require(package.Logging.parseError)

type Self<V> = Types.Computed<V>

local class = {
	kind = "state",
	type = "computed",
}

local METATABLE = table.freeze { __index = class }

local function Computed<VO>(
	scope: Types.Scope,
	processor: (Types.Use) -> VO
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
	local function use(target)
		if castToState(target) then
			depend(self, target)
		end

		return peek(target)
	end

	local success, newValue = xpcall(self._processor, parseError, use)

	if success then
		local oldValue = self._internalValue

		self._internalValue = newValue

		return not isSimilar(newValue, oldValue)
	else
		External.logErrorNonFatal("callbackError", newValue)
	end

	return false
end

table.freeze(class)

return Computed
