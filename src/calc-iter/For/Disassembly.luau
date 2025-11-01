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
	_objects: { iter.SubObject<S, IK, IV, OK, OV> },
	_constructor: (
		memory.Scope<S>,
		initial_key: IK,
		initial_value: IV
	) -> iter.SubObject<S, IK, IV, OK, OV>,
}

local function auxiliaryDestructor<S, IK, IV, OK, OV>(disassembly: Self<S, IK, IV, OK, OV>)
	for _, object in disassembly._objects do
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

		for _, object in self._objects do
			local output_key, output_value = object:useOutputPair(use)

			if output_key == nil or output_value == nil then
				has_holes = true
				continue
			elseif output[output_key] ~= nil then
				External.logErrorNonFatal(
					iter.for_key_collision,
					nil,
					tostring(output_key)
				)

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

		local current_objects = self._objects
		local next_objects = {}

		for object_key, object in current_objects do
			current_objects[object_key] = nil

			local can_reuse = false

			local cur_input_key = object.input_key
			local cur_input_value = object.input_value

			local new_input_key

			if not object.roam_keys and pending_pairs[cur_input_key] ~= nil then
				can_reuse = true
				new_input_key = cur_input_key
			else
				local claimed_values = {}

				if not object.roam_values then
					for _, other_object in current_objects do
						claimed_values[other_object.input_value] = true
					end
				end

				for pending_key, pending_value in pending_pairs do
					if
						-- "predict" that this key is going to be reused by another existing object that is
						-- expecting it to be available. if it is going to be reused, then don't.
						not object.roam_keys
						and current_objects[pending_key] ~= nil
					then
						continue
					end

					if
						-- "selfless" check
						-- don't use values that are "claimed" by other objects.
						not object.roam_values
						and cur_input_value ~= pending_value
						and claimed_values[pending_value]
					then
						continue
					end

					can_reuse = true
					new_input_key = pending_key

					if object.roam_values then
						break
					end

					if pending_value == cur_input_value then
						break
					end
				end
			end

			if can_reuse then
				local new_input_value = pending_pairs[new_input_key]

				pending_pairs[new_input_key] = nil
				next_objects[new_input_key] = object

				if new_input_key ~= cur_input_key then
					object.input_key = new_input_key
					object:invalidateInputKey()
				end

				if new_input_value ~= cur_input_value then
					object.input_value = new_input_value
					object:invalidateInputValue()
				end
			else
				if object.scope ~= nil then
					doCleanup(object.scope)
				end

				object.scope = nil
			end
		end

		-- create new pair objects for any remaining pairs that couldn't be reused.
		for pending_key, pending_value in pending_pairs do
			local new_object =
				self._constructor(deriveScope(outer_scope), pending_key, pending_value)

			next_objects[pending_key] = new_object
		end

		self._objects = next_objects

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
		created_at = os.clock(),

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
