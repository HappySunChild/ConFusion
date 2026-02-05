local async = require("./types")
local calc = require("../core-calc/types")
local graph = require("../core-graph/types")
local logging = require("../core-logging/types")
local memory = require("../core-memory/types")

local External = require("../core-external/External")

local cast_to_state = require("../core-calc/cast_to_state")
local is_similar = require("../core-calc/is_similar")

local peek = require("../core-use/peek")

local change = require("../core-graph/change")
local depend = require("../core-graph/depend")
local evaluate = require("../core-graph/evaluate")

local cleanup = require("../core-memory/cleanup")
local derive_scope = require("../core-memory/derive_scope")
local destroy_node = require("../core-memory/destroy_node")

local parse_error = require("../core-logging/parse_error")

type Self<T, S> = async.Eventual<T> & {
	_inner_scope: memory.Scope<S>,
	_processor: async.EventualProcessor<S, T>,

	_pending_value: T,
	_old_value: T?,

	_is_becoming: boolean,
	_active_thread: thread?,

	_session_used: { [graph.GraphNode]: true },
	_become: (any) -> (),
	_use: calc.Use,
}

local function handle_eventual_computation<T, S>(eventual: Self<T, S>)
	eventual._active_thread = coroutine.running()

	local inner_scope = derive_scope(eventual.scope)

	local ok, err: logging.Error =
		xpcall(eventual._processor, parse_error, eventual._use, inner_scope, eventual._become)

	if ok then -- adopt computation scope, clean up old one
		cleanup(eventual._inner_scope)
		eventual._inner_scope = inner_scope
	else -- throw away computation scope, invalidated because computation errored
		cleanup(inner_scope)
		External.log_error_nonfatal(calc.callback_error, err)
	end

	eventual._active_thread = nil
end

local CLASS = table.freeze({
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
		if self._is_becoming then
			self._is_becoming = false

			return not is_similar(self._old_value, self._cached_value)
		end

		-- cancel any currently active computations
		if self._active_thread ~= nil then
			External.cancel_task(self._active_thread)
			self._active_thread = nil
		end

		-- clear our dependencies, because we're starting a new computation that may not rely on our old dependencies
		table.clear(self._session_used)

		self._cached_value = self._pending_value
		self._old_value = self._pending_value

		-- start computation
		External.do_task_immediate(handle_eventual_computation, self)

		return not is_similar(self._old_value, self._cached_value)
	end,
	destroy = function<T, S>(self: Self<T, S>)
		if self._active_thread ~= nil then
			External.cancel_task(self._active_thread)
		end

		self._session_used = nil

		cleanup(self._inner_scope)
		self._inner_scope = nil

		destroy_node(self)
	end,
})
local METATABLE = table.freeze({ __index = CLASS })

local function generate_callbacks<T, S>(eventual: Self<T, S>): (calc.Use, (any) -> ())
	local session_used = eventual._session_used

	local function use(target: calc.UsedAs<T>): T
		if cast_to_state(target) ~= nil then
			depend(eventual, target)

			session_used[target] = true
		end

		return peek(target)
	end

	local function become(target_value: T)
		local old_value = eventual._cached_value

		eventual._old_value = old_value
		eventual._cached_value = target_value

		if eventual.validity == "busy" then
			return
		end

		eventual._is_becoming = true

		change(eventual)

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

		_cached_value = pending_value,
		_pending_value = pending_value,
		_old_value = nil,

		_using = {},
		_users = {},

		_is_becoming = false,
		_session_used = {},
		_inner_scope = nil,
		_processor = processor,
	}, METATABLE) :: any

	new_eventual._use, new_eventual._become = generate_callbacks(new_eventual)

	table.insert(scope, new_eventual)

	evaluate(new_eventual, true)

	return new_eventual
end

return Eventual
