local async = require "./types"
local graph = require "../core-graph/types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"
local castToGraph = require "../core-graph/castToGraph"
local observe = require "../core-graph/observe"

-- Pauses the current thread until the subject receives an eager update
local function await(scope: memory.Scope, subject: graph.GraphObject)
	if castToGraph(subject) == nil then
		-- i believe this should error, because if we didn't it would infitely yield a thread
		-- or cause loops that depend on it to spiral out of control
		External.logError(async.await_non_graph)
	end

	local current = coroutine.running()

	local disconnect
	disconnect = observe(scope, subject, function()
		coroutine.resume(current)

		disconnect()
	end)

	coroutine.yield()
end

return await :: async.Await
