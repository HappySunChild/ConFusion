local External = require "../External"
local Types = require "../Types"

local castToGraph = require "../Graph/castToGraph"
local evaluate = require "../Graph/evaluate"

local function change(target: Types.GraphObject)
	if not castToGraph(target) then
		External.logError("invalidChangeType", nil, typeof(target))
	end

	if not evaluate(target, true) then
		return false
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

	for _, user: Types.GraphObject in userList do
		if user.timeliness == "eager" then
			table.insert(eagerList, user)
		end
	end

	table.sort(eagerList, function(a, b)
		return a.createdAt < b.createdAt
	end)

	for _, eagerUser: Types.GraphObject in eagerList do
		evaluate(eagerUser, false)
	end

	return true
end

return change
