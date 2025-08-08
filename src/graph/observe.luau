local graph = require "./types"
local memory = require "../memory/types"

local External = require "../External"

local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"

local function observe(
	scope: memory.Scope,
	subject: graph.GraphObject,
	callback: () -> (),
	immediate: boolean?
): () -> ()
	if immediate then
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
