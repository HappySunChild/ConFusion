local calc = require("../core_calc/types")
local graph = require("../core_graph/types")

local depend = require("../core_graph/depend")

local peek = require("./peek")

local function generic_use(user: graph.GraphNode): calc.Use
	local function use<T>(target: calc.UsedAs<T>): T
		depend(user, target)

		return peek(target)
	end

	return use
end

return generic_use
