local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Computed = require(package.State.Computed)
local Observer = require(package.Graph.Observer)

local castToState = require(package.State.castToState)
local depend = require(package.Graph.depend)
local destructor = require(package.Memory.destructor)
local evaluate = require(package.Graph.evaluate)
local peek = require(package.State.peek)

local Input = Symbols.named 'Input'
local Processor = Symbols.named 'Processor'

local class = {
	type = 'for',
	kind = 'state',
}

local METATABLE = table.freeze { __index = class }

local function ForPairs<IK, IV, OK, OV>(
	scope: Types.Scope,
	input: Types.UsedAs<{ [IK]: IV }>,
	processor: (Types.Use, IK, IV) -> (OK, OV?)
): Types.ForPairs<IK, IV, OK, OV>
	local newPairs = setmetatable({
		[Symbols.Scope] = scope,
		[Symbols.CreatedAt] = os.clock(),
		[Symbols.InternalValue] = {},

		[Symbols.Users] = {},
		[Symbols.Using] = {},

		[Input] = input,
		[Processor] = processor,
	}, METATABLE)

	table.insert(scope, destructor(newPairs))

	evaluate(newPairs, true)

	return newPairs
end

function class:map(processor)
	return Computed(self[Symbols.Scope], function(use)
		return processor(use(self))
	end)
end

function class:onChange(callback)
	local observer = Observer(self[Symbols.Scope], self)

	return observer:onChange(callback), observer
end

function class:_evaluate()
	local function use(target)
		if castToState(target) then
			depend(self, target)
		end

		return peek(target)
	end

	local output = self[Symbols.InternalValue] :: {}
	table.clear(output)

	for key, value in use(self[Input]) do
		local newKey, newValue = self[Processor](use, key, value)

		output[newKey] = newValue
	end

	return true
end

table.freeze(class)

return ForPairs
