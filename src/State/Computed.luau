local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Observer = require(package.Graph.Observer)

local castToState = require(script.Parent.castToState)
local depend = require(package.Graph.depend)
local evaluate = require(package.Graph.evaluate)
local isSimilar = require(package.Utility.isSimilar)
local peek = require(script.Parent.peek)

local Processor = Symbols.named 'Processor'

local ComputedClass = {
	[Symbols.Kind] = Kinds.State,
	[Symbols.Type] = Types.Computed,
}

local METATABLE = table.freeze { __index = ComputedClass }

local function Computed<V, T>(processor: Types.ComputedProcessor<T>, debugId): Types.Computed<V, T>
	local newComputed = setmetatable({
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.Internal] = nil,
		[Symbols.DebugId] = debugId,

		[Symbols.Using] = {},
		[Symbols.Users] = {},

		[Processor] = processor,
	}, METATABLE)

	evaluate(newComputed, true)

	return newComputed
end

function ComputedClass:onChange(callback)
	local observer = Observer(self)

	return observer:onChange(callback), observer
end

function ComputedClass:map(processor)
	return Computed(function(use)
		return processor(use(self))
	end, `Computed({self[Symbols.DebugId]})`)
end

function ComputedClass:_evaluate()
	local function use(target)
		if castToState(target) then
			depend(self, target)
		end

		return peek(target)
	end

	local newValue = self[Processor](use)
	local oldValue = self[Symbols.Internal]

	self[Symbols.Internal] = newValue

	if not isSimilar(newValue, oldValue) then
		return true
	end

	return false
end

table.freeze(ComputedClass)

return Computed
