local async = require "./types"
local calc = require "../core-calc/types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local change = require "../core-graph/change"
local depend = require "../core-graph/depend"
local evaluate = require "../core-graph/evaluate"

local castToState = require "../core-calc/castToState"
local isSimilar = require "../core-calc/isSimilar"

local peek = require "../core-use/peek"

local deriveScope = require "../core-memory/deriveScope"
local destructor = require "../core-memory/destructor"
local doCleanup = require "../core-memory/doCleanup"

local parseError = require "../core-logging/parseError"

type Self<T, S> = async.Eventual<T> & {
	_innerScope: memory.Scope<S>,
	_processor: async.EventualProcessor<S, T>,

	_pendingValue: T,
	_becomeValue: T?,

	_isBecoming: boolean?,
	_activeThread: thread?,

	_become: (any) -> (),
	_use: calc.Use,
}

local function auxiliaryDestructor<T, S>(eventual: Self<T, S>)
	if eventual._activeThread ~= nil then
		External.cancelTask(eventual._activeThread)
	end

	if eventual._innerScope ~= nil then
		doCleanup(eventual._innerScope)

		eventual._innerScope = nil
	end
end

local function generateCallbacks<T, S>(eventual: Self<T, S>): (calc.Use, (any) -> ())
	local session_used = {}

	local function use<T>(target: calc.UsedAs<T>): T
		if castToState(target) then
			depend(eventual, target)

			session_used[target] = true
		end

		return peek(target)
	end

	local function become(targetValue: T)
		local becomeValue = eventual._internalValue

		eventual._internalValue = targetValue

		if eventual.validity ~= "busy" then
			eventual._becomeValue = becomeValue
			eventual._isBecoming = true

			change(eventual)

			eventual._becomeValue = nil

			for target in session_used do
				depend(eventual, target)
			end
		end
	end

	return use, become
end

local class = table.freeze {
	type = "Eventual",
	kind = "state",
	timeliness = "eager",

	isPending = function<T, S>(self: Self<T, S>)
		return self._activeThread ~= nil
	end,
	_evaluate = function<T, S>(self: Self<T, S>): boolean
		if self.scope == nil then
			return false
		end

		-- calling `become` causes the Eventual to be reevaluated, but we don't want to completely reevaluate everything
		if self._isBecoming == true then
			self._isBecoming = false

			return not isSimilar(self._becomeValue, self._internalValue)
		end

		-- cancel any currently active computations
		if self._activeThread ~= nil then
			if self._innerScope ~= nil then
				doCleanup(self._innerScope)

				self._innerScope = nil
			end

			External.cancelTask(self._activeThread)

			self._activeThread = nil
		end

		local outerScope = self.scope
		local innerScope = deriveScope(outerScope)

		self._internalValue = self._pendingValue

		local completed = false

		local activeThread = External.doTaskImmediate(function()
			local ok, err =
				xpcall(self._processor, parseError, self._use, innerScope, self._become)

			if ok then
				if self._innerScope ~= nil then
					doCleanup(self._innerScope)
				end

				self._innerScope = innerScope
			else
				doCleanup(innerScope)

				External.logErrorNonFatal(logging.callbackError, err :: logging.Error)
			end

			self._activeThread = nil

			completed = true
		end)

		-- if we didn't complete the task then update keep track of the thread
		if completed == false then
			self._activeThread = activeThread
		end

		return not isSimilar(self._internalValue, self._pendingValue)
	end,
}
local METATABLE = table.freeze { __index = class }

local function Eventual<T, S>(
	scope: memory.Scope<S>,
	processor: async.EventualProcessor<S, T>,
	pendingValue: T
): async.Eventual<T>
	local new_eventual: Self<T, S> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_internalValue = pendingValue,
		_pendingValue = pendingValue,

		_using = {},
		_users = {},

		_innerScope = nil,
		_processor = processor,
	}, METATABLE) :: any

	new_eventual._use, new_eventual._become = generateCallbacks(new_eventual)

	table.insert(scope, destructor(new_eventual, auxiliaryDestructor))

	evaluate(new_eventual, true)

	return new_eventual
end

return Eventual
