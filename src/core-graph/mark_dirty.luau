local graph = require("./types")

local External = require("../core-external/External")

local change = require("./change")
local is_eager = require("./is_eager")

--[[
	Marks a graph node as "dirty", meaning it should be re-evaluated
	as soon as possible. If it is eager, then the node is immediately re-evaluated.
]]
local function mark_dirty(node: graph.GraphNode)
	if node.validity == "busy" then
		External.log_error(graph.infinite_loop)
	elseif node.validity == "dirty" then
		return
	end

	if is_eager(node) then
		change(node) -- ok i think??

		return
	end

	node.validity = "dirty"
end

return mark_dirty
