local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local castToGraph = require(package.Graph.castToGraph)
local evaluate = require(package.Graph.evaluate)

local function change(target: Types.GraphObject)
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
				if user.validity == "valid" then
					done = false

					table.insert(userList, user)
					table.insert(searchInNext, user)
				end
			end
		end

		searchInNow, searchInNext = searchInNext, searchInNow

		table.clear(searchInNext)
	until done

	local eagerList = {}

	for _, user in userList do
		user.validity = "invalid"

		if user.timeliness == "eager" then
			table.insert(eagerList, user)
		end
	end

	table.sort(eagerList, function(a, b)
		return a.createdAt < b.createdAt
	end)

	for _, user in eagerList do
		print(user)

		user.validity = "invalid"

		evaluate(user, false)
	end

	return true
end

return change
