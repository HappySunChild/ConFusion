local async = require "./types"
local calc = require "../core-calc/types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"
local castToState = require "../core-calc/castToState"
local change = require "../core-graph/change"
local depend = require "../core-graph/depend"
local deriveScope = require "../core-memory/deriveScope"
local destructor = require "../core-memory/destructor"
local doCleanup = require "../core-memory/doCleanup"
local evaluate = require "../core-graph/evaluate"
local isSimilar = require "../core-calc/isSimilar"
local parseError = require "../core-logging/parseError"
local peek = require "../core-use/peek"

type Self<T, S> = async.Eventual<T> & {
	_inner_scope: memory.Scope<S>,
	_processor: async.EventualProcessor<S, T>,

	_pending_value: T,
	_become_value: T?,

	_is_becoming: boolean?,
	_active_thread: thread?,

	_become: (any) -> (),
	_use: calc.Use,
}

local function auxiliaryDestructor<T, S>(eventual: Self<T, S>)
	if eventual._active_thread ~= nil then
		External.cancelTask(eventual._active_thread)
	end

	if eventual._inner_scope ~= nil then
		doCleanup(eventual._inner_scope)

		eventual._inner_scope = nil
	end
end

local function generateCallbacks<T, S>(eventual: Self<T, S>): (calc.Use, (any) -> ())
	local session_used = {}

	local function use<T>(target: calc.UsedAs<T>): T
		if castToState(target) ~= nil then
			depend(eventual, target)

			session_used[target] = true
		end

		return peek(target)
	end

	local function become(targetValue: T)
		local become_value = eventual._internal_value

		eventual._internal_value = targetValue

		if eventual.validity == "busy" then
			return
		end

		eventual._become_value = become_value
		eventual._is_becoming = true

		change(eventual)

		eventual._become_value = nil

		for target in session_used do
			depend(eventual, target)
		end
	end

	return use, become
end

local CLASS = table.freeze {
	type = "Eventual",
	kind = "state",
	timeliness = "eager",

	isPending = function<T, S>(self: Self<T, S>)
		return self._active_thread ~= nil
	end,
	_evaluate = function<T, S>(self: Self<T, S>): boolean
		if self.scope == nil then
			return false
		end

		-- calling `become` causes the Eventual to be reevaluated, but we don't want to completely reevaluate everything
		if self._is_becoming == true then
			self._is_becoming = false

			return not isSimilar(self._become_value, self._internal_value)
		end

		-- cancel any currently active computations
		if self._active_thread ~= nil then
			if self._inner_scope ~= nil then
				doCleanup(self._inner_scope)

				self._inner_scope = nil
			end

			External.cancelTask(self._active_thread)

			self._active_thread = nil
		end

		local outer_scope = self.scope
		local inner_scope = deriveScope(outer_scope)

		self._internal_value = self._pending_value

		local completed = false

		local active_thread = External.doTaskImmediate(function()
			local ok, err =
				xpcall(self._processor, parseError, self._use, inner_scope, self._become)

			if ok then
				if self._inner_scope ~= nil then
					doCleanup(self._inner_scope)
				end

				self._inner_scope = inner_scope
			else
				doCleanup(inner_scope)

				External.logErrorNonFatal(logging.callbackError, err :: logging.Error)
			end

			self._active_thread = nil

			completed = true
		end)

		-- if we didn't complete the task then update keep track of the thread
		if completed == false then
			self._active_thread = active_thread
		end

		return not isSimilar(self._internal_value, self._pending_value)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function Eventual<T, S>(
	scope: memory.Scope<S>,
	processor: async.EventualProcessor<S, T>,
	pending_value: T
): async.Eventual<T>
	local new_eventual: Self<T, S> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_internal_value = pending_value,
		_pending_value = pending_value,

		_using = {},
		_users = {},

		_inner_scope = nil,
		_processor = processor,
	}, METATABLE) :: any

	new_eventual._use, new_eventual._become = generateCallbacks(new_eventual)

	table.insert(scope, destructor(new_eventual, auxiliaryDestructor))

	evaluate(new_eventual, true)

	return new_eventual
end

return Eventual
