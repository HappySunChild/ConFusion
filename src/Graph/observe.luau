local External = require "../External"
local Types = require "../Types"

local castToGraph = require "./castToGraph"
local evaluate = require "./evaluate"

local OBSERVER_META = table.freeze {
	__index = table.freeze {
		type = "Observer",
		kind = "observer",
	},
}

local function observe(target: Types.GraphObject, callback: () -> (), immediate: boolean?)
	if not castToGraph(target) then
		return
	end

	evaluate(target)

	local observers = target._observers

	if not observers then
		observers = {}

		target._observers = observers
	end

	if immediate then
		External.doTaskImmediate(callback)
	end

	local uniqueIdentifier = {}
	local newObserver = table.freeze(setmetatable({
		callback = callback,
		createdAt = os.clock(),
	}, OBSERVER_META))

	observers[uniqueIdentifier] = newObserver

	return function()
		observers[uniqueIdentifier] = nil
	end
end

return observe
