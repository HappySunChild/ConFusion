local graph = require("@fusion/core_graph/types")
local memory = require("@fusion/core_memory/types")

local destructor = require("@fusion/core_memory/destructor")

local CLASS = table.freeze({
	timeliness = "lazy",
	type = "Graph",

	_evaluate = function()
		return true
	end,
})
local METATABLE = table.freeze({ __index = CLASS })

local function GraphNode(scope: memory.Scope, is_eager: boolean?): graph.GraphNode
	local new_graphnode = setmetatable({
		scope = scope,
		created_at = os.clock(),
		validity = "valid",
		timeliness = if is_eager then "eager" else nil,

		_users = {},
		_using = {},
	}, METATABLE)

	local oldest_task = destructor(new_graphnode)
	new_graphnode._oldest_task = oldest_task

	table.insert(scope, oldest_task)

	return new_graphnode
end

return GraphNode
