local graph = require "../core-graph/types"

-- A generic destroy function for graph objects, so you don't have to rewrite the same thing 1000 times
local function generic_destroy(target: graph.GraphObject)
	local scope = target.scope

	if scope ~= nil then
		local index = table.find(scope, target)

		table.remove(scope, index)
	end

	target.scope = nil

	local using = target._using

	for dependency in using do
		dependency._users[target] = nil
		using[dependency] = nil
	end

	local users = target._users

	for user in users do
		user._using[target] = nil
		users[user] = nil
	end
end

return generic_destroy
