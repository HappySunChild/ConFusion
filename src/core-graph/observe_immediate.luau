local graph = require("./types")
local memory = require("../core-memory/types")

local External = require("../core-external/External")

local observe = require("./observe")

--[[
	Adds an observer callback to a graph node after immediately calling the callback.
	This has the side effect of also making the node eager.
	
	Returns a disconnect function that removes the observer callback from the node.
]]
local function observe_immediate(
	scope: memory.Scope,
	subject: graph.GraphNode,
	callback: () -> ()
): (() -> ())?
	External.do_task_immediate(callback)

	return observe(scope, subject, callback)
end

return observe_immediate
