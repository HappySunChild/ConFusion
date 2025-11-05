local calc = require "../core-calc/types"
local iter = require "../iter/types"
local iter_for = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"
local castToState = require "../core-calc/castToState"
local depend = require "../core-graph/depend"
local deriveScope = require "../core-memory/deriveScope"
local destructor = require "../core-memory/destructor"
local doCleanup = require "../core-memory/doCleanup"
local peek = require "../core-use/peek"

type Self<S, IK, IV, OK, OV> = iter.Disassembly<OK, OV> & {
	_roam_keys: boolean,
	_roam_values: boolean,

	_input: calc.UsedAs<{ [IK]: IV }>,
	_computedpairs: { [IK]: iter_for.ComputedPair<IK, IV, OK, OV> },
	_constructor: (
		memory.Scope<S>,
		initial_key: IK,
		initial_value: IV
	) -> iter_for.ComputedPair<IK, IV, OK, OV>,
}

local function auxiliaryDestructor<S, IK, IV, OK, OV>(disassembly: Self<S, IK, IV, OK, OV>)
	for _, computedpair in disassembly._computedpairs do
		doCleanup(computedpair.scope)
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

		for _, computedpair in self._computedpairs do
			local output_key: OK?, output_value: OV? = computedpair:useOutputPair(use)

			if output_key == nil or output_value == nil then
				has_holes = true
				continue
			elseif output[output_key] ~= nil then
				External.logErrorNonFatal(
					iter.for_key_collision,
					nil,
					output_key,
					computedpair.input_key,
					computedpair.input_value,
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
		if castToState(self._input) ~= nil then
			depend(self, self._input)
		end

		local roam_keys = self._roam_keys
		local roam_values = self._roam_values

		local pending_pairs = table.clone(peek(self._input)) :: { [IK]: IV }

		local current_computedpairs = self._computedpairs
		local next_computedpairs = {}

		for index, computedpair in current_computedpairs do
			current_computedpairs[index] = nil

			local old_input_key = computedpair.input_key
			local old_input_value = computedpair.input_value

			local new_input_key: IK

			local can_reuse = false

			if not roam_keys and pending_pairs[old_input_key] ~= nil then
				can_reuse = true
				new_input_key = old_input_key
			else
				local claimed_values = {}

				if not roam_values then
					for _, other_computedpair in current_computedpairs do
						claimed_values[other_computedpair.input_value] = true
					end
				end

				for pending_key, pending_value in pending_pairs do
					if
						-- "predict" that this key is going to be reused by another existing object that is
						-- expecting it to be available. if it is going to be reused, then don't.
						not roam_keys and current_computedpairs[pending_key] ~= nil
					then
						continue
					end

					if
						-- "selfless" check
						-- don't use values that are "claimed" by other objects.
						not roam_values
						and old_input_value ~= pending_value
						and claimed_values[pending_value] == true
					then
						continue
					end

					can_reuse = true
					new_input_key = pending_key

					if roam_values then
						break
					end

					if pending_value == old_input_value then
						break
					end
				end
			end

			-- cleanup computed pair that can't be reused
			if not can_reuse then
				doCleanup(computedpair.scope)

				continue
			end

			local new_input_value: IV = pending_pairs[new_input_key]

			pending_pairs[new_input_key] = nil
			next_computedpairs[new_input_key] = computedpair

			if old_input_key ~= new_input_key then
				computedpair.input_key = new_input_key
				computedpair:invalidateInputKey()
			end

			if old_input_value ~= new_input_value then
				computedpair.input_value = new_input_value
				computedpair:invalidateInputValue()
			end
		end

		local outer_scope = self.scope

		-- create new pair objects for any remaining pairs that couldn't be reused.
		for pending_key, pending_value in pending_pairs do
			next_computedpairs[pending_key] =
				self._constructor(deriveScope(outer_scope), pending_key, pending_value)
		end

		self._computedpairs = next_computedpairs

		return true
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function ForDisassembly<S, IK, IV, OK, OV>(
	scope: memory.Scope,
	roam_keys: boolean,
	roam_values: boolean,
	input: calc.UsedAs<{ [IK]: IV }>,
	constructor: (
		memory.Scope<S>,
		initial_key: IK,
		initial_value: IV
	) -> iter_for.ComputedPair<IK, IV, OK, OV>
): iter.Disassembly<OK, OV>
	local new_disassembly: Self<S, IK, IV, OK, OV> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_users = {},
		_using = {},

		_roam_keys = roam_keys,
		_roam_values = roam_values,

		_input = input,
		_computedpairs = {},
		_constructor = constructor,
	}, METATABLE) :: any

	table.insert(scope, destructor(new_disassembly, auxiliaryDestructor))

	return new_disassembly
end

return ForDisassembly
