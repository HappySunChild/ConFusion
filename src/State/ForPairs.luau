local package = script.Parent.Parent

local External = require(package.External)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Computed = require(package.State.Computed)

local castToState = require(package.State.castToState)
local depend = require(package.Graph.depend)
local destructor = require(package.Memory.destructor)
local evaluate = require(package.Graph.evaluate)
local observe = require(package.Graph.observe)
local parseError = require(package.Logging.parseError)
local peek = require(package.State.peek)

local Input = Symbols.named "Input"
local OldInput = Symbols.named "OldInput"
local Objects = Symbols.named "Objects"
local Processor = Symbols.named "Processor"

local class = {
	type = "for",
	kind = "state",
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

		[OldInput] = nil,
		[Input] = input,
		[Processor] = processor,
		[Objects] = {},
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
	return observe(self, callback)
end

function class:_evaluate()
	local function use(target)
		if castToState(target) then
			depend(self, target)
		end

		return peek(target)
	end

	local scope = self[Symbols.Scope]
	local objects = self[Objects]

	local oldInput = self[OldInput]
	local newInput = use(self[Input])

	local processor = self[Processor] :: (Types.Use, any, any) -> (any, any)

	if oldInput then
		for key, value in newInput do
			if oldInput[key] ~= value then
				local pair = Computed(scope, function(use)
					local ok, newKey, newValue =
						xpcall(processor, parseError, use, key, value)

					if ok then
						return { key = newKey, value = newValue }
					end

					External.logErrorNonFatal("callbackError", newKey :: Types.Error)

					return { key = key, value = value }
				end)

				objects[key] = pair
			end
		end

		for key in oldInput do
			if newInput[key] == nil then
				objects[key] = nil
			end
		end
	end

	local output = self[Symbols.InternalValue] :: {}
	table.clear(output)

	for _, pairObject in objects do
		local pair = use(pairObject)
		local key, value = pair.key, pair.value

		output[key] = value
	end

	self[OldInput] = table.clone(newInput)

	return true
end

table.freeze(class)

return ForPairs
