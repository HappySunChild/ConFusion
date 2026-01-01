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

type Self<S, IK, IV, OK> = iter_for.ComputedPair<IK, IV, OK, IV> & {
	_inner_scope: memory.Scope<S>,
	_processor: iter_for.ForValuesProcessor<S, IK, OK>,
	_use: calc.Use,
}

local CLASS = table.freeze {
	type = "State",
	kind = "ComputedPair (ForKeys)",

	invalidate_pair = function<S, IK, IV, OV>(self: Self<S, IK, IV, OV>, new_key: IK, new_value: IV)
		self._input_value = new_value
		self._internal_value.value = new_value

		if not is_similar(self._input_key, new_key) then
			self._input_key = new_key

			mark_dirty(self)
		end
	end,

	_evaluate = function<S, IK, IV, OV>(self: Self<S, IK, IV, OV>)
		if self.scope == nil then
			return false
		end

		local inner_scope = derive_scope(self.scope)
		local ok, new_key =
			xpcall(self._processor, parse_error, self._use, inner_scope, self._input_key)

		if not ok then
			destroy(inner_scope)

			External.log_error_nonfatal(calc.callback_error, new_key :: logging.Error)

			return false
		end

		destroy(self._inner_scope)
		self._inner_scope = inner_scope

		local output = self._internal_value
		local old_key = output.key

		output.key = new_key

		return not is_similar(old_key, new_key)
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

local function ForKeysComputedPair<S, IK, IV, OK>(
	scope: memory.Scope<S>,
	initial_key: IK,
	initial_value: IV,
	processor: iter_for.ForKeysProcessor<
		S,
		IK,
		OK
	>
)
	local new_computedpair = setmetatable({
		created_at = os.clock(),
		scope = scope,

		_using = {},
		_users = {},

		_internal_value = { key = nil, value = initial_value },

		_input_key = initial_key,
		_input_value = initial_value,

		_inner_scope = nil,
		_processor = processor,
	}, METATABLE)

	new_computedpair._use = generic_use(new_computedpair)

	table.insert(scope, new_computedpair)

	return new_computedpair
end

local function ForKeys<S, IK, IV, OK>(
	scope: memory.Scope<S>,
	input_table: calc.UsedAs<{ [IK]: IV }>,
	processor: iter_for.ForKeysProcessor<S, IK, OK>
): iter.Iter<OK, IV> | { [OK]: IV }
	local can_dissolve, constant = check_dissolvable(scope, input_table, processor)

	if can_dissolve then
		return constant
	end

	return Iter(
		scope,
		ForDisassembly(
			scope,
			false,
			true,
			input_table,
			function(scope: memory.Scope<S>, initial_key: IK, initial_value: IV)
				return ForKeysComputedPair(scope, initial_key, initial_value, processor)
			end
		)
	)
end

return ForKeys
