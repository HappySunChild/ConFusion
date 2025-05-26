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

-- after using this for a while, i'm starting to hate it.
-- maybe I should just switch it back to the base Fusion Observer system
-- not only is this messy, but it doesn't really give you much control over when they're cleaned up, outside the disconnect function.

-- I was thinking of adding a scope parameter, but it's not that hard to just table.insert the returned disconnect function into an existing scope.
-- these observers are already tied to their subjects but i feel like you should still be able to easily clean them up,
-- so i may go through with the scope paramater.
-- it'd be nice if observers could also be pooled aswell, instead of just creating a new observer each time.
-- i don't know how'd that work though

local function observe(
	subject: Types.GraphObject,
	callback: () -> (),
	immediate: boolean?
): (() -> ())?
	if not castToGraph(subject) then
		return nil
	end

	evaluate(subject)

	if type(subject._observers) ~= "table" then
		subject._observers = {}
	end

	if immediate then
		External.doTaskImmediate(callback)
	end

	local uniqueIdentifier = table.freeze {}

	subject._observers[uniqueIdentifier] = table.freeze(setmetatable({
		callback = callback,
		createdAt = os.clock(),
	}, OBSERVER_META))

	return function()
		if not subject._observers then
			return
		end

		subject._observers[uniqueIdentifier] = nil
	end
end

return observe
