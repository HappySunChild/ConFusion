local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local Computed = require(package.State.Computed)
local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

local depend = require(package.Graph.depend)
local evaluate = require(package.Graph.evaluate)
local observe = require(package.Graph.observe)

local destructor = require(package.Memory.destructor)

local parseError = require(package.Logging.parseError)

type Self<IK, IV, OK, OV> = Types.For<IK, IV, OK, OV> & {
	_objects: { [IK]: Types.Computed<unknown, { key: OK, value: OV }> },
	_lastInput: { [IK]: IV },
	_input: { [IK]: IV },
	_processor: (Types.Use, IK, IV) -> (OK, OV),
}

local class = {
	type = "for",
	kind = "state",
}

local METATABLE = table.freeze { __index = class }

local function For<IK, IV, OK, OV>(
	scope: Types.Scope,
	input: Types.UsedAs<{ [IK]: IV }>,
	processor: (Types.Use, IK, IV) -> (OK, OV?)
): Types.For<IK, IV, OK, OV>
	local newFor = setmetatable({
		scope = scope,
		_createdAt = os.clock(),
		_internalValue = {},

		_users = {},
		_using = {},

		_objects = {},
		_lastInput = {},
		_input = input,
		_processor = processor,
	}, METATABLE) :: Self<IK, IV, OK, OV>

	table.insert(scope, destructor(newFor))

	evaluate(newFor, true)

	return newFor
end

function class.map<IK, IV, OK, OV>(self: Self<IK, IV, OK, OV>, processor)
	return Computed(self.scope, function(use)
		return processor(use(self))
	end)
end

function class.onChange<IK, IV, OK, OV>(self: Self<IK, IV, OK, OV>, callback)
	return observe(self, callback)
end

function class._evaluate<IK, IV, OK, OV>(self: Self<IK, IV, OK, OV>)
	local function use(target)
		if castToState(target) then
			depend(self, target)
		end

		return peek(target)
	end

	local scope = self.scope
	local objects = self._objects

	local lastInput = self._lastInput
	local input = use(self._input)

	local processor = self._processor

	for key, value in input do
		if lastInput[key] ~= value then
			local pair = Computed(scope, function(use)
				local ok, newKey, newValue =
					xpcall(processor, parseError, use, use(key), use(value))

				if ok then
					return { key = newKey, value = newValue }
				end

				External.logErrorNonFatal("callbackError", newKey :: Types.Error)

				return { key = key, value = value }
			end)

			objects[key] = pair
		end
	end

	for key in lastInput do
		if input[key] == nil then
			objects[key] = nil
		end
	end

	local output = self._internalValue :: {}
	table.clear(output)

	for _, pairObject in objects do
		local pair = use(pairObject)
		local key, value = pair.key, pair.value

		output[key] = value
	end

	self._lastInput = table.clone(input)

	return true
end

table.freeze(class)

return For
