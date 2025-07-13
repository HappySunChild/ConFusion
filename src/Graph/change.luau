--!strict
local External = require "../External"
local Types = require "../Types"

local castToGraph = require "../Graph/castToGraph"
local evaluate = require "../Graph/evaluate"

local function _isEager(target: Types.GraphObject)
	if target.timeliness == "eager" then
		return true
	end

	-- after doing a bit of analysis I concluded that observers essentialy turn their subjects into eager graph objects
	-- this is because observers are by their nature eager, and they always depend on their subjects
	-- and since theyre always depending on their subjects, their subjects are always being eagerly evaluated.

	if target._observers then
		return next(target._observers) ~= nil
	end

	return false
end

local function _fireObservers(target: Types.GraphObject)
	if target._observers == nil then
		return
	end

	for _, callback in target._observers do
		External.doTaskImmediate(callback)
	end
end

local function change(target: Types.GraphObject)
	if not castToGraph(target) then
		External.logError("invalidChangeType", nil, typeof(target))
	end

	if not evaluate(target, true) then
		return false
	end

	local eagerList = {} :: { Types.GraphObject }

	local searchInNow = { target }
	local searchInNext = {}

	repeat
		local done = true

		for _, searchTarget: Types.GraphObject in searchInNow do
			for user in searchTarget._users do
				if user.validity == "busy" then
					External.logError "infiniteLoop"
				end

				if user.validity == "valid" then
					user.validity = "invalid"

					done = false

					table.insert(searchInNext, user)

					if _isEager(user) then
						table.insert(eagerList, user)
					end
				end
			end
		end

		searchInNow, searchInNext = searchInNext, searchInNow

		table.clear(searchInNext)
	until done

	table.sort(eagerList, function(a, b)
		return a.createdAt < b.createdAt
	end)

	_fireObservers(target)

	for _, eagerUser in eagerList do
		-- fire observers if there was a significant change
		if evaluate(eagerUser) then
			_fireObservers(eagerUser)
		end
	end

	return true
end

return change
