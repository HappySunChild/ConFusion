local graph = require "../core-graph/types"

--- A generic destroy function for graph nodes.
local function destroy_node(node: graph.GraphNode)
	local scope = node.scope

	if scope ~= nil then
		local index = table.find(scope, node)

		table.remove(scope, index)
	end

	node.scope = nil

	local using = node._using

	for dependency in using do
		dependency._users[node] = nil
		using[dependency] = nil
	end

	local users = node._users

	for user in users do
		user._using[node] = nil
		users[user] = nil
	end
end

return destroy_node
