local calc = require "../core-calc/types"
local iter_range = require "./types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local Computed = require "../core-calc/Computed"
local External = require "../core-external/External"
local Value = require "../core-calc/Value"
local doCleanup = require "../core-memory/doCleanup"
local parseError = require "../core-logging/parseError"

type Self<T> = {
	_input_index_state: calc.Value<number>,
	_output_value_state: calc.Computed<T>,
} & iter_range.RangePair<T>

local CLASS = table.freeze {
	invalidate = function<T>(self: Self<T>)
		self._input_index_state:set(self.input_index)
	end,
	useOutput = function<T>(self: Self<T>, use: calc.Use): T
		return use(self._output_value_state)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function RangePair<S, T>(
	scope: memory.Scope<S>,
	initial_index: number,
	processor: iter_range.RangeDisassemblyProcessor<S, T>
): iter_range.RangePair<T>
	local input_index_state = Value(scope, initial_index)
	local output_value_state = Computed(
		scope,
		function(use: calc.Use, calc_scope: memory.Scope<S>)
			local input_index = use(input_index_state)
			local ok, output_value =
				xpcall(processor, parseError, use, calc_scope, input_index)

			if ok then
				return output_value
			end

			External.logErrorNonFatal(calc.callback_error, output_value :: logging.Error)

			doCleanup(calc_scope)

			return nil
		end
	)

	local new_subobject = setmetatable({
		scope = scope,
		input_index = initial_index,

		_input_index_state = input_index_state,
		_output_value_state = output_value_state,
	}, METATABLE)

	return new_subobject
end

return RangePair
