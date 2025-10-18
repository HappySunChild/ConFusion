local graph = require "./types"

local External = require "../External"

local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"

local function _isEager(target: graph.GraphObject)
	if target.timeliness == "eager" then
		return true
	end

	if target._observers ~= nil then
		return next(target._observers) ~= nil
	end

	return false
end

local function _fireObservers(target: graph.GraphObject)
	if target._observers == nil then
		return
	end

	for _, callback in target._observers do
		External.doTaskImmediate(callback)
	end
end

local function change(target: graph.GraphObject)
	if not castToGraph(target) then
		return External.logError(graph.invalidChangeType, nil, typeof(target))
	end

	if not evaluate(target, true) then
		return
	end

	local search_now = { target }
	local search_next = {}

	local eager_users = {}

	repeat
		local done = true

		for _, searchTarget: graph.GraphObject in search_now do
			for user in searchTarget._users do
				if user.validity == "busy" then
					External.logError(graph.infiniteLoop)
				end

				if user.validity == "valid" then
					user.validity = "invalid"

					done = false

					table.insert(search_next, user)

					if _isEager(user) then
						table.insert(eager_users, user)
					end
				end
			end
		end

		search_now, search_next = search_next, search_now

		table.clear(search_next)
	until done

	table.sort(eager_users, function(a, b)
		return a.createdAt < b.createdAt
	end)

	_fireObservers(target)

	for _, user: graph.GraphObject in eager_users do
		if evaluate(user) then
			_fireObservers(user)
		end
	end

	return true
end

return change
