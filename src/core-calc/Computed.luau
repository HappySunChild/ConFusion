local calc = require "./types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local parseError = require "../core-logging/parseError"

local dissolvingUse = require "../core-use/dissolvingUse"
local genericUse = require "../core-use/genericUse"

local deriveScope = require "../core-memory/deriveScope"
local destructor = require "../core-memory/destructor"
local doCleanup = require "../core-memory/doCleanup"
local innerScope = require "../core-memory/innerScope"

local isSimilar = require "./isSimilar"

type Self<T, S> = calc.Computed<T> & {
	_innerScope: memory.Scope<S>?,
	_processor: calc.ComputedProcessor<S, T>,
	_use: calc.Use,
}

local function auxiliaryDestructor<T, S>(computed: Self<T, S>)
	if computed._innerScope ~= nil then
		doCleanup(computed._innerScope)

		computed._innerScope = nil
	end
end

local function checkDissolvable<T, S>(
	scope: memory.Scope<S>,
	processor: calc.ComputedProcessor<S, T>
): (boolean, T?)
	local dissolvingScope = innerScope(scope)
	local success, value = pcall(processor, dissolvingUse, dissolvingScope)

	if success then
		-- scope went unused, we can clean it up
		if #dissolvingScope == 1 then
			doCleanup(dissolvingScope)
		end

		return true, value
	end

	doCleanup(dissolvingScope)

	return false
end

local class = table.freeze {
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
			local similar = isSimilar(self._internalValue, new_value)

			if self._innerScope ~= nil then
				doCleanup(self._innerScope)

				self._innerScope = nil
			end

			self._innerScope = inner_scope
			self._internalValue = new_value

			return not similar
		else
			doCleanup(inner_scope)

			External.logErrorNonFatal(logging.callbackError, new_value :: logging.Error)
		end

		return false
	end,
}
local METATABLE = table.freeze { __index = class }

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
		createdAt = os.clock(),
		_internalValue = nil,

		_using = {},
		_users = {},

		_innerScope = nil,
		_processor = processor,
	}, METATABLE) :: any

	new_computed._use = genericUse(new_computed)

	table.insert(scope, destructor(new_computed, auxiliaryDestructor))

	return new_computed
end

return Computed
