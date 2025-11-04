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
	_computed_pairs: { [IK]: iter.ComputedPair<IK, IV, OK, OV> },
	_constructor: (
		memory.Scope<S>,
		initial_key: IK,
		initial_value: IV
	) -> iter.ComputedPair<IK, IV, OK, OV>,
}

local function auxiliaryDestructor<S, IK, IV, OK, OV>(disassembly: Self<S, IK, IV, OK, OV>)
	for _, computed_pair in disassembly._computed_pairs do
		if computed_pair.scope ~= nil then
			doCleanup(computed_pair.scope)

			computed_pair.scope = nil
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

		for _, computed_pair in self._computed_pairs do
			local output_key, output_value = computed_pair:useOutputPair(use)

			if output_key == nil or output_value == nil then
				has_holes = true
				continue
			elseif output[output_key] ~= nil then
				External.logErrorNonFatal(
					iter.for_key_collision,
					nil,
					output_key,
					computed_pair.input_key,
					computed_pair.input_value,
					output_key,
					output_value
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

		local current_computed_pairs = self._computed_pairs
		local next_computed_pairs = {}

		for index, computed_pair in current_computed_pairs do
			current_computed_pairs[index] = nil

			local old_input_key = computed_pair.input_key
			local old_input_value = computed_pair.input_value

			local new_input_key: IK

			local can_reuse = false

			if not computed_pair.roam_keys and pending_pairs[old_input_key] ~= nil then
				can_reuse = true
				new_input_key = old_input_key
			else
				local claimed_values = {}

				if not computed_pair.roam_values then
					for _, other_object in current_computed_pairs do
						claimed_values[other_object.input_value] = true
					end
				end

				for pending_key, pending_value in pending_pairs do
					if
						-- "predict" that this key is going to be reused by another existing object that is
						-- expecting it to be available. if it is going to be reused, then don't.
						not computed_pair.roam_keys
						and current_computed_pairs[pending_key] ~= nil
					then
						continue
					end

					if
						-- "selfless" check
						-- don't use values that are "claimed" by other objects.
						not computed_pair.roam_values
						and old_input_value ~= pending_value
						and claimed_values[pending_value]
					then
						continue
					end

					can_reuse = true
					new_input_key = pending_key

					if computed_pair.roam_values then
						break
					end

					if pending_value == old_input_value then
						break
					end
				end
			end

			-- cleanup computed pair that can't be reused
			if not can_reuse then
				if computed_pair.scope ~= nil then
					doCleanup(computed_pair.scope)

					computed_pair.scope = nil
				end

				continue
			end

			local new_input_value: IV = pending_pairs[new_input_key]

			pending_pairs[new_input_key] = nil
			next_computed_pairs[new_input_key] = computed_pair

			if old_input_key ~= new_input_key then
				computed_pair.input_key = new_input_key
				computed_pair:invalidateInputKey()
			end

			if old_input_value ~= new_input_value then
				computed_pair.input_value = new_input_value
				computed_pair:invalidateInputValue()
			end
		end

		-- create new pair objects for any remaining pairs that couldn't be reused.
		for pending_key, pending_value in pending_pairs do
			local new_pair =
				self._constructor(deriveScope(outer_scope), pending_key, pending_value)

			next_computed_pairs[pending_key] = new_pair
		end

		self._computed_pairs = next_computed_pairs

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
	) -> iter.ComputedPair<IK, IV, OK, OV>
): iter.Disassembly<S, IK, IV, OK, OV>
	local new_disassembly: Self<S, IK, IV, OK, OV> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_users = {},
		_using = {},

		_input = input,
		_computed_pairs = {},
		_constructor = constructor,
	}, METATABLE) :: any

	table.insert(scope, destructor(new_disassembly, auxiliaryDestructor))

	return new_disassembly
end

return Disassembly
