local graph = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"
local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"
local nameOf = require "../core-logging/nameOf"
local nicknames = require "../core-logging/nicknames"

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

	local unique_identifier = {}
	subject._observers[unique_identifier] = callback

	evaluate(subject)

	local function disconnect()
		subject._observers[unique_identifier] = nil

		local index = table.find(scope, disconnect)

		if index ~= nil then
			table.remove(scope, index)
		end
	end

	nicknames[disconnect] = `Observer ({nameOf(subject, "unknown")})`

	table.insert(scope, disconnect)

	return disconnect
end

return observe :: graph.Observe
