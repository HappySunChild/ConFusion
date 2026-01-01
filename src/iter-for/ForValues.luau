local calc = require "../core-calc/types"
local iter = require "../iter/types"
local iter_for = require "./types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local is_similar = require "../core-calc/is_similar"

local derive_scope = require "../core-memory/derive_scope"
local destroy = require "../core-memory/destroy"
local generic_destroy = require "../core-memory/generic_destroy"

local parse_error = require "../core-logging/parse_error"

local mark_dirty = require "../core-graph/mark_dirty"

local generic_use = require "../core-use/generic_use"

local Iter = require "../iter/Iter"

local ForDisassembly = require "./ForDisassembly"
local check_dissolvable = require "./check_dissolvable"

type Self<S, IK, IV, OV> = iter_for.ComputedPair<IK, IV, IK, OV> & {
	_inner_scope: memory.Scope<S>,
	_processor: iter_for.ForValuesProcessor<S, IV, OV>,
	_use: calc.Use,
}

local CLASS = table.freeze {
	type = "State",
	kind = "ComputedPair (ForValues)",

	invalidate_pair = function<S, IK, IV, OV>(self: Self<S, IK, IV, OV>, new_key: IK, new_value: IV)
		self._input_key = new_key
		self._internal_value.key = new_key

		if not is_similar(self._input_value, new_value) then
			self._input_value = new_value

			mark_dirty(self)
		end
	end,

	_evaluate = function<S, IK, IV, OV>(self: Self<S, IK, IV, OV>)
		if self.scope == nil then
			return false
		end

		local inner_scope = derive_scope(self.scope)
		local ok, new_value = xpcall(
			self._processor,
			parse_error,
			self._use,
			inner_scope,
			self._input_value
		)

		if not ok then
			destroy(inner_scope)

			External.log_error_nonfatal(calc.callback_error, new_value :: logging.Error)

			return false
		end

		destroy(self._inner_scope)
		self._inner_scope = inner_scope

		local output = self._internal_value
		local old_value = output.value

		output.value = new_value

		return not is_similar(old_value, new_value)
	end,
	destroy = function<S, IK, IV, OV>(self: Self<S, IK, IV, OV>)
		destroy(self._inner_scope)
		self._inner_scope = nil

		self._input_key = nil
		self._input_value = nil

		generic_destroy(self)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function ForValuesComputedPair<S, IK, IV, OV>(
	scope: memory.Scope<S>,
	initial_key: IK,
	initial_value: IV,
	processor: iter_for.ForValuesProcessor<
		S,
		IV,
		OV
	>
): Self<S, IK, IV, OV>
	local new_computedpair = setmetatable({
		created_at = os.clock(),
		scope = scope,

		_using = {},
		_users = {},

		_internal_value = { key = initial_key, value = nil },

		_input_key = initial_key,
		_input_value = initial_value,

		_inner_scope = nil,
		_processor = processor,
	}, METATABLE)

	new_computedpair._use = generic_use(new_computedpair)

	table.insert(scope, new_computedpair)

	return new_computedpair
end

local function ForValues<S, IK, IV, OV>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: iter_for.ForValuesProcessor<S, IV, OV>
): iter.Iter<IK, OV> | { [IK]: OV }
	local can_dissolve, constant = check_dissolvable(
		scope,
		input_table,
		function(use: calc.Use, scope: memory.Scope<S>, input_key: IK, input_value: IV)
			local new_value = processor(use, scope, input_value)

			return input_key, new_value
		end
	)

	if can_dissolve then
		return constant
	end

	return Iter(
		scope,
		ForDisassembly(
			scope,
			true,
			false,
			input_table,
			function(scope: memory.Scope<S>, initial_key: IK, initial_value: IV)
				return ForValuesComputedPair(scope, initial_key, initial_value, processor)
			end
		)
	)
end

return ForValues
