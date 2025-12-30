local graph = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"

local observe = require "./observe"

local function observe_immediate(
	scope: memory.Scope,
	subject: graph.GraphObject,
	callback: () -> ()
): (() -> ())?
	External.do_task_immediate(callback)

	return observe(scope, subject, callback)
end

return observe_immediate :: graph.Observe
