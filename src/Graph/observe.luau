local External = require "../External"
local Types = require "../Types"

local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"

-- this function serves as a most integrated system for Observers.
-- instead of being another node in the graph, they are built into each node, and are fired when there is a significant change
local function observe(
	scope: Types.Scope,
	subject: Types.GraphObject,
	callback: () -> (),
	immediate: boolean?
)
	if immediate == true then
		External.doTaskImmediate(callback)
	end

	if castToGraph(subject) == nil then
		return
	end

	if subject._observers == nil then
		subject._observers = {}
	end

	local uniqueId = {}

	subject._observers[uniqueId] = callback

	evaluate(subject)

	local function disconnect()
		subject._observers[uniqueId] = nil

		local index = table.find(scope, disconnect)

		if index then
			table.remove(scope, index)
		end
	end

	table.insert(scope, disconnect)

	return disconnect
end

return observe
