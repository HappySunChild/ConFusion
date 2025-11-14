local graph = require "./types"
local memory = require "../core-memory/types"

local nameOf = require "../core-logging/nameOf"
local nicknames = require "../core-logging/nicknames"

local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"

local function observe(
	scope: memory.Scope,
	subject: graph.GraphObject,
	callback: () -> ()
): (() -> ())?
	if castToGraph(subject) == nil then
		return nil
	end

	if subject._observers == nil then
		subject._observers = {}
	end

	table.insert(subject._observers, callback)

	evaluate(subject)

	local function disconnect()
		local observe_index = table.find(subject._observers, callback)

		if observe_index ~= nil then
			table.remove(subject._observers, observe_index)
		end

		local disconnect_index = table.find(scope, disconnect)

		if disconnect_index ~= nil then
			table.remove(scope, disconnect_index)
		end
	end

	nicknames[disconnect] = `Observer ({nameOf(subject, "unknown")})`

	table.insert(scope, disconnect)

	return disconnect
end

return observe :: graph.Observe
