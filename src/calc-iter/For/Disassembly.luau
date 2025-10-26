local calc = require "../../core-calc/types"
local iter = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"

local deriveScope = require "../../core-memory/deriveScope"
local destructor = require "../../core-memory/destructor"
local doCleanup = require "../../core-memory/doCleanup"

local peek = require "../../core-use/peek"

local depend = require "../../core-graph/depend"

local castToState = require "../../core-calc/castToState"

type Self<S, IK, IV, OK, OV> = iter.Disassembly<S, IK, IV, OK, OV> & {
	_input: calc.UsedAs<{ [IK]: IV }>,
	_objects: { [iter.SubObject<S, IK, IV, OK, OV>]: boolean },
	_constructor: (
		memory.Scope<S>,
		initialKey: IK,
		initialValue: IV
	) -> iter.SubObject<S, IK, IV, OK, OV>,
}

local function auxiliaryDestructor<S, IK, IV, OK, OV>(disassembly: Self<S, IK, IV, OK, OV>)
	for object in disassembly._objects do
		if object.scope ~= nil then
			doCleanup(object.scope)

			object.scope = nil
		end
	end
end

local class = table.freeze {
	type = "Disassembly",
	kind = "graph",
	timeliness = "eager",

	populate = function<S, IK, IV, OK, OV>(
		self: Self<S, IK, IV, OK, OV>,
		use: calc.Use,
		output: { [OK]: OV? }
	)
		local minArrayIndex = math.huge
		local maxArrayIndex = -math.huge
		local hasHoles = false

		for object in self._objects do
			local outputKey, outputValue = object:useOutputPair(use)

			if outputKey == nil or outputValue == nil then
				hasHoles = true
				continue
			elseif output[outputKey] ~= nil then
				External.logErrorNonFatal(iter.forKeyCollision, nil, tostring(outputKey))

				continue
			end

			output[outputKey] = outputValue

			if type(outputKey) == "number" then
				minArrayIndex = math.min(minArrayIndex, outputKey :: number)
				maxArrayIndex = math.max(maxArrayIndex, outputKey :: number)
			end
		end

		if hasHoles and maxArrayIndex < minArrayIndex then
			local moveToIndex = minArrayIndex

			for moveFromIndex = minArrayIndex, maxArrayIndex do
				local outputValue = output[moveFromIndex] :: any

				if outputValue == nil then
					continue
				end

				output[moveFromIndex] = nil
				output[moveToIndex] = outputValue
				moveToIndex += 1
			end
		end
	end,
	_evaluate = function<S, IK, IV, OK, OV>(self: Self<S, IK, IV, OK, OV>)
		local outerScope = self.scope :: memory.Scope

		if castToState(self._input) then
			depend(self, self._input)
		end

		local pendingPairs = table.clone(peek(self._input)) :: { [any]: any }
		local newObjects = {}

		for object in self._objects do
			local reused = false

			-- casting these to unknown because the type solver doesn't know how to handle generics, apparently.
			local oldInputKey = object.inputKey :: unknown
			local oldInputValue = object.inputValue :: unknown

			local newInputKey

			if not object.roamKeys and pendingPairs[oldInputKey] ~= nil then
				reused = true
				newInputKey = oldInputKey
			else
				for pendingKey, pendingValue in pendingPairs do
					reused = true
					newInputKey = pendingKey

					if object.roamValues then
						break
					end

					if pendingValue == oldInputValue then
						break
					end
				end
			end

			if reused then
				local newInputValue = pendingPairs[newInputKey]
				newObjects[object] = true

				if newInputKey ~= oldInputKey then
					object.inputKey = newInputKey
					object:invalidateInputKey()
				end

				if newInputValue ~= oldInputValue then
					object.inputValue = newInputValue
					object:invalidateInputValue()
				end

				pendingPairs[newInputKey] = nil
			else
				if object.scope ~= nil then
					doCleanup(object.scope)
				end

				object.scope = nil
			end
		end

		for pendingKey, pendingValue in pendingPairs do
			local object =
				self._constructor(deriveScope(outerScope), pendingKey, pendingValue)
			newObjects[object] = true
		end

		self._objects = newObjects

		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function Disassembly<S, IK, IV, OK, OV>(
	scope: memory.Scope,
	input: calc.UsedAs<{ [IK]: IV }>,
	constructor: (
		memory.Scope<S>,
		initialKey: IK,
		initialValue: IV
	) -> iter.SubObject<S, IK, IV, OK, OV>
): iter.Disassembly<S, IK, IV, OK, OV>
	local newDisassembly: Self<S, IK, IV, OK, OV> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},
		_using = {},

		_input = input,
		_constructor = constructor,
		_objects = {},
	}, METATABLE) :: any

	table.insert(scope, destructor(newDisassembly, auxiliaryDestructor))

	return newDisassembly
end

return Disassembly
