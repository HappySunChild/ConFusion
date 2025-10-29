local graph = require "./types"

local External = require "../core-external/External"
local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"
local nameOf = require "../core-logging/nameOf"

local function depend(user: graph.GraphObject, dependency: graph.GraphObject)
	if castToGraph(dependency) == nil then
		return
	end

	evaluate(dependency)

	if table.isfrozen(user._using) or table.isfrozen(dependency._users) then
		External.logError(
			graph.cannotDepend,
			nil,
			nameOf(user, "User"),
			table.isfrozen(user._using) and "FROZEN" or "NOT FROZEN",
			nameOf(dependency, "Dependency"),
			table.isfrozen(dependency._users) and "FROZEN" or "NOT FROZEN"
		)
	end

	user._using[dependency] = true
	dependency._users[user] = true
end

return depend
