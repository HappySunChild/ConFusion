local calc = require "../../core-calc/types"
local iter = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"
local castToState = require "../../core-calc/castToState"
local depend = require "../../core-graph/depend"
local deriveScope = require "../../core-memory/deriveScope"
local destructor = require "../../core-memory/destructor"
local doCleanup = require "../../core-memory/doCleanup"
local peek = require "../../core-use/peek"

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

local CLASS = table.freeze {
	type = "Disassembly",
	kind = "graph",
	timeliness = "eager",

	populate = function<S, IK, IV, OK, OV>(
		self: Self<S, IK, IV, OK, OV>,
		use: calc.Use,
		output: { [OK]: OV? }
	)
		local min_array_index = math.huge
		local max_array_index = -math.huge
		local has_holes = false

		for object in self._objects do
			local output_key, output_value = object:useOutputPair(use)

			if output_key == nil or output_value == nil then
				has_holes = true
				continue
			elseif output[output_key] ~= nil then
				External.logErrorNonFatal(iter.forKeyCollision, nil, tostring(output_key))

				continue
			end

			output[output_key] = output_value

			if type(output_key) == "number" then
				min_array_index = math.min(min_array_index, output_key :: number)
				max_array_index = math.max(max_array_index, output_key :: number)
			end
		end

		if has_holes and max_array_index < min_array_index then
			local move_to_index = min_array_index

			for move_from_index = min_array_index, max_array_index do
				local output_value = output[move_from_index] :: any

				if output_value == nil then
					continue
				end

				output[move_from_index] = nil
				output[move_to_index] = output_value
				move_to_index += 1
			end
		end
	end,
	_evaluate = function<S, IK, IV, OK, OV>(self: Self<S, IK, IV, OK, OV>)
		local outer_scope = self.scope :: memory.Scope

		if castToState(self._input) ~= nil then
			depend(self, self._input)
		end

		local pending_pairs = table.clone(peek(self._input)) :: { [any]: any }
		local new_objects = {}

		for object in self._objects do
			local reused = false

			-- casting these to unknown because the type solver doesn't know how to handle generics, apparently.
			local old_input_key = object.inputKey :: unknown
			local old_input_value = object.inputValue :: unknown

			local new_input_key

			if not object.roamKeys and pending_pairs[old_input_key] ~= nil then
				reused = true
				new_input_key = old_input_key
			else
				for pending_key, pending_value in pending_pairs do
					reused = true
					new_input_key = pending_key

					if object.roamValues then
						break
					end

					if pending_value == old_input_value then
						break
					end
				end
			end

			if reused then
				local new_input_value = pending_pairs[new_input_key]
				new_objects[object] = true

				if new_input_key ~= old_input_key then
					object.inputKey = new_input_key
					object:invalidateInputKey()
				end

				if new_input_value ~= old_input_value then
					object.inputValue = new_input_value
					object:invalidateInputValue()
				end

				pending_pairs[new_input_key] = nil
			else
				if object.scope ~= nil then
					doCleanup(object.scope)
				end

				object.scope = nil
			end
		end

		for pending_key, pending_value in pending_pairs do
			local object =
				self._constructor(deriveScope(outer_scope), pending_key, pending_value)
			new_objects[object] = true
		end

		self._objects = new_objects

		return true
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function Disassembly<S, IK, IV, OK, OV>(
	scope: memory.Scope,
	input: calc.UsedAs<{ [IK]: IV }>,
	constructor: (
		memory.Scope<S>,
		initial_key: IK,
		initial_value: IV
	) -> iter.SubObject<S, IK, IV, OK, OV>
): iter.Disassembly<S, IK, IV, OK, OV>
	local new_disassembly: Self<S, IK, IV, OK, OV> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},
		_using = {},

		_input = input,
		_constructor = constructor,
		_objects = {},
	}, METATABLE) :: any

	table.insert(scope, destructor(new_disassembly, auxiliaryDestructor))

	return new_disassembly
end

return Disassembly
