local calc = require "./types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"
local deriveScope = require "../core-memory/deriveScope"
local destructor = require "../core-memory/destructor"
local dissolvingUse = require "../core-use/dissolvingUse"
local doCleanup = require "../core-memory/doCleanup"
local genericUse = require "../core-use/genericUse"
local innerScope = require "../core-memory/innerScope"
local isSimilar = require "./isSimilar"
local parseError = require "../core-logging/parseError"

type Self<T, S> = calc.Computed<T> & {
	_inner_scope: memory.Scope<S>?,
	_processor: calc.ComputedProcessor<S, T>,
	_use: calc.Use,
}

local function auxiliaryDestructor<T, S>(computed: Self<T, S>)
	if computed._inner_scope ~= nil then
		doCleanup(computed._inner_scope)

		computed._inner_scope = nil
	end
end

local function checkDissolvable<T, S>(
	scope: memory.Scope<S>,
	processor: calc.ComputedProcessor<S, T>
): (boolean, T?)
	local dissolving_scope = innerScope(scope)
	local success, value = pcall(processor, dissolvingUse, dissolving_scope)

	if success then
		-- scope went unused, we can clean it up
		if #dissolving_scope == 1 then
			doCleanup(dissolving_scope)
		end

		return true, value
	end

	doCleanup(dissolving_scope)

	return false
end

local CLASS = table.freeze {
	type = "Computed",
	kind = "state",
	timeliness = "lazy",

	_evaluate = function<T, S>(self: Self<T, S>): boolean
		if self.scope == nil then
			return false
		end

		local outer_scope = self.scope
		local inner_scope = deriveScope(outer_scope)

		local ok, new_value = xpcall(self._processor, parseError, self._use, inner_scope)

		if ok then
			local similar = isSimilar(self._internal_value, new_value)

			if self._inner_scope ~= nil then
				doCleanup(self._inner_scope)

				self._inner_scope = nil
			end

			self._inner_scope = inner_scope
			self._internal_value = new_value

			return not similar
		else
			doCleanup(inner_scope)

			External.logErrorNonFatal(logging.callback_error, new_value :: logging.Error)
		end

		return false
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function Computed<T, S>(
	scope: memory.Scope<S>,
	processor: calc.ComputedProcessor<S, T>
): calc.Computed<T>
	local can_dissolve, constant = checkDissolvable(scope, processor)

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

	new_computed._use = genericUse(new_computed)

	table.insert(scope, destructor(new_computed, auxiliaryDestructor))

	return new_computed
end

return Computed
