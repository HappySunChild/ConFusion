local graph = require "./types"

local function castToGraph(target: unknown): graph.GraphObject?
	if
		typeof(target) == "table"
		and target.created_at ~= nil
		and target._users ~= nil
		and target._using ~= nil
	then
		return target
	end

	return nil
end

return castToGraph
