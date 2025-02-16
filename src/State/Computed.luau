local package = script.Parent.Parent

local External = require(package.External)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local castToState = require(package.State.castToState)
local depend = require(package.Graph.depend)
local destructor = require(package.Memory.destructor)
local evaluate = require(package.Graph.evaluate)
local isSimilar = require(package.Utility.isSimilar)
local observe = require(package.Graph.observe)
local parseError = require(package.Logging.parseError)
local peek = require(package.State.peek)

local Processor = Symbols.named 'Processor'

local class = {
	kind = 'state',
	type = 'computed',
}

local METATABLE = table.freeze { __index = class }

local function Computed<V, VO>(
	scope: Types.Scope,
	processor: Types.ComputedProcessor<VO>
): Types.Computed<V, VO>
	local newComputed = setmetatable({
		[Symbols.Scope] = scope,
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.InternalValue] = nil,

		[Symbols.Using] = {},
		[Symbols.Users] = {},

		[Processor] = processor,
	}, METATABLE)

	table.insert(scope, destructor(newComputed))

	evaluate(newComputed, true)

	return newComputed
end

function class:onChange(callback)
	return observe(self, callback)
end

function class:map(processor)
	return Computed(self[Symbols.Scope], function(use)
		return processor(use(self))
	end)
end

function class:_evaluate()
	local function use(target)
		if castToState(target) then
			depend(self, target)
		end

		return peek(target)
	end

	local success, newValue = xpcall(self[Processor], parseError, use)

	if success then
		local oldValue = self[Symbols.InternalValue]

		self[Symbols.InternalValue] = newValue

		return not isSimilar(newValue, oldValue)
	else
		External.logErrorNonFatal('callbackError', newValue)
	end

	return false
end

table.freeze(class)

return Computed
