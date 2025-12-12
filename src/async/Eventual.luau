local async = require "./types"
local calc = require "../core-calc/types"
local logging = require "../core-logging/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local cast_to_state = require "../core-calc/cast_to_state"
local is_similar = require "../core-calc/is_similar"

local peek = require "../core-use/peek"

local change = require "../core-graph/change"
local depend = require "../core-graph/depend"
local evaluate = require "../core-graph/evaluate"

local derive_scope = require "../core-memory/derive_scope"
local destroy = require "../core-memory/destroy"
local destructor = require "../core-memory/destructor"

local parse_error = require "../core-logging/parse_error"

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

local CLASS = table.freeze {
	type = "State",
	kind = "Eventual",
	timeliness = "eager",

	is_pending = function<T, S>(self: Self<T, S>)
		return self._active_thread ~= nil
	end,
	_evaluate = function<T, S>(self: Self<T, S>): boolean
		if self.scope == nil then
			return false
		end

		-- calling `become` causes the Eventual to be reevaluated, but we don't want to completely reevaluate everything
		if self._is_becoming == true then
			self._is_becoming = false

			return not is_similar(self._become_value, self._internal_value)
		end

		-- cancel any currently active computations
		if self._active_thread ~= nil then
			if self._inner_scope ~= nil then
				destroy(self._inner_scope)

				self._inner_scope = nil
			end

			External.cancel_task(self._active_thread)

			self._active_thread = nil
		end

		local outer_scope = self.scope
		local inner_scope = derive_scope(outer_scope)

		self._internal_value = self._pending_value

		local completed = false

		local active_thread = External.do_task_immediate(function()
			local ok, err =
				xpcall(self._processor, parse_error, self._use, inner_scope, self._become)

			if ok then
				if self._inner_scope ~= nil then
					destroy(self._inner_scope)
				end

				self._inner_scope = inner_scope
			else
				destroy(inner_scope)

				External.log_error_nonfatal(calc.callback_error, err :: logging.Error)
			end

			self._active_thread = nil

			completed = true
		end)

		-- if we didn't complete the task then update keep track of the thread
		if completed == false then
			self._active_thread = active_thread
		end

		return not is_similar(self._internal_value, self._pending_value)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function auxiliary_destructor<T, S>(eventual: Self<T, S>)
	if eventual._active_thread ~= nil then
		External.cancel_task(eventual._active_thread)
	end

	destroy(eventual._inner_scope)

	eventual._inner_scope = nil
end

local function generate_callbacks<T, S>(eventual: Self<T, S>): (calc.Use, (any) -> ())
	local session_used = {}

	local function use<T>(target: calc.UsedAs<T>): T
		if cast_to_state(target) ~= nil then
			depend(eventual, target)

			session_used[target] = true
		end

		return peek(target)
	end

	local function become(target_value: T)
		local become_value = eventual._internal_value

		eventual._internal_value = target_value

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

	new_eventual._use, new_eventual._become = generate_callbacks(new_eventual)

	table.insert(scope, destructor(new_eventual, auxiliary_destructor))

	evaluate(new_eventual, true)

	return new_eventual
end

return Eventual
