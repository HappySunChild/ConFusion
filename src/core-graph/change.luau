local graph = require "./types"

local External = require "../core-external/External"

local cast_to_graph = require "./cast_to_graph"
local evaluate = require "./evaluate"
local is_eager = require "./is_eager"

local function fire_node_observers(node: graph.GraphNode)
	if node._observers == nil then
		return
	end

	for _, callback in node._observers do
		External.do_task_immediate(callback)
	end
end

local function gather_eager_users(node: graph.GraphNode): { graph.GraphNode }
	local eager_users: { graph.GraphNode } = {}

	local search_now: { graph.GraphNode } = { node }
	local search_next: { graph.GraphNode } = {}

	repeat
		local is_finished = true

		for _, searching: graph.GraphNode in search_now do
			for user in searching._users do
				if user.validity == "busy" then
					External.log_error(graph.infinite_loop)
				end

				if user.validity == "valid" then
					user.validity = "invalid"

					is_finished = false

					table.insert(search_next, user)

					if is_eager(user) then
						table.insert(eager_users, user)
					end
				end
			end
		end

		search_now, search_next = search_next, search_now

		table.clear(search_next)
	until is_finished

	table.sort(eager_users, function(x: graph.GraphNode, y: graph.GraphNode)
		return x.created_at < y.created_at
	end)

	return eager_users
end

--[[
	Prompts a graph node to be re-evaluated. If it meaningfully
	changes, then dependents will be marked invalid and will have to be
	re-evaluated at a later point (or immediately if it is eager).

	https://fluff.blog/2024/04/16/monotonic-painting.html
]]
local function change(node: graph.GraphNode)
	if cast_to_graph(node) == nil then
		External.log_error(graph.invalid_change_type, nil, typeof(node))
	end

	if not evaluate(node, true) then
		return
	end

	local eager_users = gather_eager_users(node)

	fire_node_observers(node)

	for _, user: graph.GraphNode in eager_users do
		if evaluate(user) then
			fire_node_observers(user)
		end
	end
end

return change
