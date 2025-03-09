local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local castToGraph = require(package.Graph.castToGraph)
local evaluate = require(package.Graph.evaluate)

local function collectObservers(target: Types.GraphObject, output: {})
	if target._observers ~= nil then
		for callback in target._observers do
			table.insert(output, callback)
		end
	end

	return output
end

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

	table.sort(userList, function(a, b)
		return a.createdAt < b.createdAt
	end)

	local observers = collectObservers(target, {})
	local eagerList = {}

	for _, user: Types.GraphObject in userList do
		collectObservers(user, observers)

		if user.timeliness == "eager" then
			table.insert(eagerList, user)
		end
	end

	for _, eagerUser: Types.GraphObject in eagerList do
		evaluate(eagerUser, false)
	end

	for _, callback in observers do
		External.doTaskImmediate(callback)
	end

	return true
end

return change
