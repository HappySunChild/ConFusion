local graph = require "./types"

local External = require "../core-external/External"

local name_of = require "../core-logging/name_of"

local check_lifetime = require "../core-memory/check_lifetime"

local cast_to_graph = require "./cast_to_graph"
local evaluate = require "./evaluate"

local function depend_lifetime_formatter(a: unknown, b: unknown): (string, string)
	return `The dependency '{name_of(b, "object")}'`, `the user '{name_of(a, "object")}'`
end

local function depend(user: graph.GraphNode, dependency: graph.GraphNode)
	if cast_to_graph(dependency) == nil then
		return
	end

	check_lifetime(user, dependency, dependency.scope, depend_lifetime_formatter)

	evaluate(dependency)

	if table.isfrozen(user._using) or table.isfrozen(dependency._users) then
		External.log_error(
			graph.cannot_depend,
			nil,
			name_of(user, "User object"),
			table.isfrozen(user._using) and "FROZEN" or "NOT FROZEN",
			name_of(dependency, "Dependency object"),
			table.isfrozen(dependency._users) and "FROZEN" or "NOT FROZEN"
		)
	end

	user._using[dependency] = true
	dependency._users[user] = true
end

return depend
