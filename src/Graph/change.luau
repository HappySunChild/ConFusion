local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local castToGraph = require(package.Graph.castToGraph)
local evaluate = require(package.Graph.evaluate)
local notify = require(package.Graph.notify)

local function change(target: Types.GraphObject)
	if not castToGraph(target) then
		return External.logError("invalidChangeType", nil, typeof(target))
	end

	if not evaluate(target, true) then
		return
	end

	-- notify changed object's observers
	notify(target)

	local searchInNow = { target }
	local searchInNext = {}
	local eagerList = {}

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

					if user.timeliness == "eager" then
						table.insert(eagerList, user)
					end
				end

				notify(user)
			end
		end

		searchInNow, searchInNext = searchInNext, searchInNow

		table.clear(searchInNext)
	until done

	table.sort(eagerList, function(a, b)
		return a.createdAt < b.createdAt
	end)

	for _, eagerUser in eagerList do
		evaluate(eagerUser, false)
	end

	return true
end

return change
