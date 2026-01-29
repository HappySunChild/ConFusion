local calc = require "../core-calc/types"
local iter_range = require "./types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local is_similar = require "../core-calc/is_similar"

local destroy = require "../core-memory/destroy"
local destroy_node = require "../core-memory/destroy_node"

local parse_error = require "../core-logging/parse_error"

local mark_dirty = require "../core-graph/mark_dirty"

local generic_use = require "../core-use/generic_use"

local derive_scope = require "../core-memory/derive_scope"

type Self<T, S> = {
	_inner_scope: memory.Scope<S>,
	_processor: iter_range.RangeDisassemblyProcessor<T, S>,
	_use: calc.Use,

	_input_index: number,
} & iter_range.RangePair<T>

local CLASS = table.freeze {
	type = "State",
	kind = "RangePair",
	timeliness = "lazy",

	invalidate_index = function<T, S>(self: Self<T, S>, new_index: number)
		if is_similar(self._input_index, new_index) then
			return
		end

		self._input_index = new_index

		mark_dirty(self)
	end,

	_evaluate = function<T, S>(self: Self<T, S>)
		if self.scope == nil then
			return false
		end

		local inner_scope = derive_scope(self.scope)
		local ok, output_value = xpcall(
			self._processor,
			parse_error,
			self._use,
			inner_scope,
			self._input_index
		)

		if not ok then
			destroy(inner_scope)

			External.log_error_nonfatal(
				calc.callback_error,
				output_value :: logging.Error
			)

			return false
		end

		destroy(self._inner_scope)
		self._inner_scope = inner_scope

		local old_value = self._cached_value

		self._cached_value = output_value

		return not is_similar(old_value, output_value)
	end,
	destroy = function<T, S>(self: Self<T, S>)
		destroy(self._inner_scope)
		self._inner_scope = nil

		destroy_node(self)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function RangePair<S, T>(
	scope: memory.Scope<S>,
	initial_index: number,
	processor: iter_range.RangeDisassemblyProcessor<S, T>
): iter_range.RangePair<T>
	local new_rangepair: Self<T, S> = setmetatable({
		scope = scope,
		created_at = os.clock(),
		_cached_value = nil,

		_using = {},
		_users = {},

		_input_index = initial_index,

		_inner_scope = nil,
		_processor = processor,
	}, METATABLE) :: any

	new_rangepair._use = generic_use(new_rangepair)

	table.insert(scope, new_rangepair)

	return new_rangepair
end

return RangePair
