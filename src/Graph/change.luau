local package = script.Parent.Parent

local Types = require(package.Types)

local castToState = require(package.State.castToState)
local evaluate = require(package.Graph.evaluate)

local function change(target: Types.GraphObject)
	if not castToState(target) then
		return
	end

	if not evaluate(target, true) then
		return
	end

	target._lastChange = os.clock()

	local searchInNow = { target }
	local searchInNext = {}
	local userList = {}

	repeat
		local done = true

		for _, searchTarget in searchInNow do
			for user in searchTarget._users do
				if user._validity == 'valid' then
					done = false

					table.insert(userList, user)
					table.insert(searchInNext, user)
				end
			end
		end

		searchInNow, searchInNext = searchInNext, searchInNow

		table.clear(searchInNext)
	until done

	table.sort(userList, function(a, b)
		return a._createdAt < b._createdAt
	end)

	for _, user in userList do
		user._validity = 'invalid'

		evaluate(user, false)
	end
end

return change
