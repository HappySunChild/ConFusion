local graph = require "./types"

local External = require "../core-external/External"

local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"

local function fireNodeObservers(target: graph.GraphObject)
	if target._observers == nil then
		return
	end

	for _, callback in target._observers do
		External.doTaskImmediate(callback)
	end
end

local function isNodeEager(target: graph.GraphObject): boolean
	if target.timeliness == "eager" then
		return true
	end

	if target._observers ~= nil then
		return next(target._observers) ~= nil
	end

	return false
end

local function gatherEagerUsers(target: graph.GraphObject): { graph.GraphObject }
	local eager_users: { graph.GraphObject } = {}

	local search_now: { graph.GraphObject } = { target }
	local search_next: { graph.GraphObject } = {}

	repeat
		local is_finished = true

		for _, searching: graph.GraphObject in search_now do
			for user in searching._users do
				if user.validity == "busy" then
					External.logError(graph.infinite_loop)
				end

				if user.validity == "valid" then
					user.validity = "invalid"

					is_finished = false

					table.insert(search_next, user)

					if isNodeEager(user) then
						table.insert(eager_users, user)
					end
				end
			end
		end

		search_now, search_next = search_next, search_now

		table.clear(search_next)
	until is_finished

	table.sort(eager_users, function(x: graph.GraphObject, y: graph.GraphObject)
		return x.created_at < y.created_at
	end)

	return eager_users
end

local function change(target: graph.GraphObject)
	if castToGraph(target) == nil then
		External.logError(graph.invalid_change_type, nil, typeof(target))
	end

	if not evaluate(target, true) then
		return
	end

	local eager_users = gatherEagerUsers(target)

	fireNodeObservers(target)

	for _, user: graph.GraphObject in eager_users do
		if evaluate(user) then
			fireNodeObservers(user)
		end
	end

	return true
end

return change
