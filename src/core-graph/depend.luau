local graph = require "./types"

local External = require "../core-external/External"

local name_of = require "../core-logging/name_of"

local cast_to_graph = require "./cast_to_graph"
local evaluate = require "./evaluate"

local function depend(user: graph.GraphObject, dependency: graph.GraphObject)
	if cast_to_graph(dependency) == nil then
		return
	end

	evaluate(dependency)

	if table.isfrozen(user._using) or table.isfrozen(dependency._users) then
		External.log_error(
			graph.cannot_depend,
			nil,
			name_of(user, "User"),
			table.isfrozen(user._using) and "FROZEN" or "NOT FROZEN",
			name_of(dependency, "Dependency"),
			table.isfrozen(dependency._users) and "FROZEN" or "NOT FROZEN"
		)
	end

	user._using[dependency] = true
	dependency._users[user] = true
end

return depend
