local graph = require "./types"

local External = require "../External"

local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"

local kindof = require "../kindof"

local function change(target: graph.GraphObject)
	if not castToGraph(target) then
		return External.logError("invalidChangeType", nil, typeof(target))
	end

	if not evaluate(target, true) then
		return
	end

	local searchInNow = { target }
	local searchInNext = {}
	local userList = {}

	repeat
		local done = true

		for _, searchTarget in searchInNow do
			for user in searchTarget._users do
				if user.validity == "busy" then
					return External.logError "infiniteLoop"
				end

				if user.validity == "valid" then
					user.validity = "invalid"

					done = false

					table.insert(searchInNext, user)
					table.insert(userList, user)
				end
			end
		end

		searchInNow, searchInNext = searchInNext, searchInNow

		table.clear(searchInNext)
	until done

	local eagerList = {}

	for _, user: graph.GraphObject in userList do
		if user.timeliness == "eager" then
			table.insert(eagerList, user)
		end
	end

	table.sort(eagerList, function(a, b)
		return a.createdAt < b.createdAt
	end)

	for _, eagerUser: graph.GraphObject in eagerList do
		-- this feels a little gross, making a special case just for observers.
		-- but it works *okayyyy*
		if kindof(eagerUser) == "observer" then
			eagerUser.callback()

			continue
		end

		evaluate(eagerUser, false)
	end

	return true
end

return change
