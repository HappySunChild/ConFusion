local External = require "../External"
local Types = require "../Types"

local depend = require "../Graph/depend"

local castToState = require "./castToState"
local dissolvingUse = require "./dissolvingUse"
local peek = require "./peek"

local deriveScope = require "../Memory/deriveScope"
local destructor = require "../Memory/destructor"
local doCleanup = require "../Memory/doCleanup"
local innerScope = require "../Memory/innerScope"

local isSimilar = require "../Utility/isSimilar"

local parseError = require "../Logging/parseError"

type Self<T, S> = Types.Computed<T> & {
	_innerScope: Types.Scope<S>?,
	_processor: (use: Types.Use, scope: Types.Scope<S>) -> T,
}

local class = table.freeze {
	type = "Computed",
	kind = "state",
	timeliness = "lazy",

	_evaluate = function<T, S>(self: Self<T, S>): boolean
		if self.scope == nil then
			return false
		end

		local outerScope = self.scope
		local innerScope = deriveScope(outerScope)

		local function use<V>(target: Types.UsedAs<V>): V
			if castToState(target) then
				depend(self, target)
			end

			return peek(target)
		end

		local ok, newValue = xpcall(self._processor, parseError, use, innerScope)

		if ok then
			local similar = isSimilar(self._internalValue, newValue)

			if self._innerScope ~= nil then
				doCleanup(self._innerScope)

				self._innerScope = nil
			end

			self._innerScope = innerScope
			self._internalValue = newValue

			return not similar
		else
			doCleanup(innerScope)

			External.logErrorNonFatal("callbackError", newValue)
		end

		return false
	end,
}
local METATABLE = table.freeze { __index = class }

local function _checkDissolvable<T, S>(
	scope: Types.Scope<S>,
	processor: (Types.Use, Types.Scope<S>) -> T
): (boolean, T?)
	local success, value = pcall(processor, dissolvingUse, scope)

	if success then
		return true, value
	end

	doCleanup(scope)

	return false
end

local function Computed<T, S>(
	scope: Types.Scope<S>,
	processor: (Types.Use, Types.Scope<S>) -> T
): Types.Computed<T> | T
	local dissolvable, value = _checkDissolvable(innerScope(scope), processor)

	if dissolvable then
		return value
	end

	local newComputed: Self<T, S> = setmetatable({
		scope = scope,
		createdAt = os.clock(),
		_internalValue = nil,

		_using = {},
		_users = {},

		_innerScope = nil,
		_processor = processor,
	}, METATABLE) :: any

	table.insert(scope, {
		destructor(newComputed),
		function()
			if newComputed._innerScope ~= nil then
				doCleanup(newComputed._innerScope)

				newComputed._innerScope = nil
			end
		end,
	})

	return newComputed
end

return Computed
