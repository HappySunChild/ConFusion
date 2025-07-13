local External = require "../External"
local Types = require "../Types"

local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"

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

	local uniqueIdentifier = {}
	subject._observers[uniqueIdentifier] = callback

	local function disconnect()
		subject._observers[uniqueIdentifier] = nil

		local index = table.find(scope, disconnect)

		if index then
			table.remove(scope, index)
		end
	end

	table.insert(scope, disconnect)

	evaluate(subject)

	return disconnect
end

return observe
