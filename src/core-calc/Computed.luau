local calc = require "./types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local derive_scope = require "../core-memory/derive_scope"
local destroy = require "../core-memory/destroy"
local generic_destroy = require "../core-memory/generic_destroy"
local inner_scope = require "../core-memory/inner_scope"

local dissolving_use = require "../core-use/dissolving_use"
local generic_use = require "../core-use/generic_use"

local parse_error = require "../core-logging/parse_error"

local is_similar = require "./is_similar"

type Self<T, S> = calc.Computed<T> & {
	_inner_scope: memory.Scope<S>?,
	_processor: calc.ComputedProcessor<S, T>,
	_use: calc.Use,
}

local CLASS = table.freeze {
	type = "State",
	kind = "Computed",
	timeliness = "lazy",

	_evaluate = function<T, S>(self: Self<T, S>): boolean
		if self.scope == nil then
			return false
		end

		local outer_scope = self.scope
		local inner_scope = derive_scope(outer_scope)

		local ok, new_value = xpcall(self._processor, parse_error, self._use, inner_scope)

		if ok then
			local similar = is_similar(self._internal_value, new_value)

			destroy(self._inner_scope)

			self._inner_scope = inner_scope
			self._internal_value = new_value

			return not similar
		end

		destroy(inner_scope)

		External.log_error_nonfatal(calc.callback_error, new_value :: logging.Error)

		return false
	end,
	destroy = function<T, S>(self: Self<T, S>)
		destroy(self._inner_scope)
		self._inner_scope = nil

		generic_destroy(self)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function check_dissolvable<T, S>(
	scope: memory.Scope<S>,
	processor: calc.ComputedProcessor<S, T>
): (boolean, T?)
	local dissolving_scope = inner_scope(scope)
	local success, value = pcall(processor, dissolving_use, dissolving_scope)

	if success then
		-- scope went unused, we can clean it up
		if #dissolving_scope == 1 then
			destroy(dissolving_scope)
		end

		return true, value
	end

	destroy(dissolving_scope)

	return false
end

local function Computed<T, S>(
	scope: memory.Scope<S>,
	processor: calc.ComputedProcessor<S, T>
): calc.Computed<T>
	local can_dissolve, constant = check_dissolvable(scope, processor)

	if can_dissolve then
		return constant
	end

	local new_computed: Self<T, S> = setmetatable({
		scope = scope,
		created_at = os.clock(),
		_internal_value = nil,

		_using = {},
		_users = {},

		_inner_scope = nil,
		_processor = processor,
	}, METATABLE) :: any

	new_computed._use = generic_use(new_computed)

	table.insert(scope, new_computed)

	return new_computed
end

return Computed
