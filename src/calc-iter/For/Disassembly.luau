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
	_pairs: { [IK]: iter.Pair<IK, IV, OK, OV> },
	_constructor: (
		memory.Scope<S>,
		initial_key: IK,
		initial_value: IV
	) -> iter.Pair<IK, IV, OK, OV>,
}

local function auxiliaryDestructor<S, IK, IV, OK, OV>(disassembly: Self<S, IK, IV, OK, OV>)
	for _, object in disassembly._pairs do
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

		for _, object in self._pairs do
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

		local current_pairs = self._pairs
		local next_pairs = {}

		for pair_key, pair in current_pairs do
			current_pairs[pair_key] = nil

			local can_reuse = false

			local cur_input_key = pair.input_key
			local cur_input_value = pair.input_value

			local new_input_key

			if not pair.roam_keys and pending_pairs[cur_input_key] ~= nil then
				can_reuse = true
				new_input_key = cur_input_key
			else
				local claimed_values = {}

				if not pair.roam_values then
					for _, other_object in current_pairs do
						claimed_values[other_object.input_value] = true
					end
				end

				for pending_key, pending_value in pending_pairs do
					if
						-- "predict" that this key is going to be reused by another existing object that is
						-- expecting it to be available. if it is going to be reused, then don't.
						not pair.roam_keys and current_pairs[pending_key] ~= nil
					then
						continue
					end

					if
						-- "selfless" check
						-- don't use values that are "claimed" by other objects.
						not pair.roam_values
						and cur_input_value ~= pending_value
						and claimed_values[pending_value]
					then
						continue
					end

					can_reuse = true
					new_input_key = pending_key

					if pair.roam_values then
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
				next_pairs[new_input_key] = pair

				if new_input_key ~= cur_input_key then
					pair.input_key = new_input_key
					pair:invalidateInputKey()
				end

				if new_input_value ~= cur_input_value then
					pair.input_value = new_input_value
					pair:invalidateInputValue()
				end
			else
				if pair.scope ~= nil then
					doCleanup(pair.scope)
				end

				pair.scope = nil
			end
		end

		-- create new pair objects for any remaining pairs that couldn't be reused.
		for pending_key, pending_value in pending_pairs do
			local new_pair =
				self._constructor(deriveScope(outer_scope), pending_key, pending_value)

			next_pairs[pending_key] = new_pair
		end

		self._pairs = next_pairs

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
	) -> iter.Pair<IK, IV, OK, OV>
): iter.Disassembly<S, IK, IV, OK, OV>
	local new_disassembly: Self<S, IK, IV, OK, OV> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_users = {},
		_using = {},

		_input = input,
		_pairs = {},
		_constructor = constructor,
	}, METATABLE) :: any

	table.insert(scope, destructor(new_disassembly, auxiliaryDestructor))

	return new_disassembly
end

return Disassembly
