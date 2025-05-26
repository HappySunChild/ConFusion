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

--[[
after using this for a while, i'm starting to hate it.
maybe I should just switch it back to the base Fusion Observer system
not only is this messy, but it doesn't really give you much control over when they're cleaned up, outside the disconnect function.

I was thinking of adding a scope parameter, but it's not that hard to just table.insert the returned disconnect function into an existing scope.
these observers are already tied to their subjects but i feel like you should still be able to easily clean them up,
so i may go through with the scope paramater.
it'd be nice if observers could also be pooled aswell, instead of just creating a new observer each time.
i don't know how'd that work though

after thinking for a while, implementing the scope paramater seems kind of tricky. i guess i could have it insert the disconnect into the passed scope,
but then what if we disconnect manually, then there'd still be the disconnect callback in the scope.
do we manually remove the callback from the scope?
that seems like it'd get pretty expensive, especially if there are a lot of tasks after the observer.

alternatively we could just not return the disconnect callback, but that feels too limiting, and like we're relying too much on the scope to just
handle everything.

(also observers are usually pretty high level, users will often be creating and disconnecting them.
having to clean up an entire scope to disconnect observers seems a little tedious)

it doesn't really matter anyway since the observer will get cleaned up with the subject because it's
tied to the subject.

something i thought about after typing this is that the observer will always be cleaned up before the subject, it has to. unless we're observing some
value in a different scope tree, which sounds more like a user problem. again there's still the 'what-if-we-already-disconnected-the-observer' problem.
i guess it's fine if we keep the function in the scope after manual disconnection, but it just feels wrong leaving it in the scope since it wouldn't
do anything.

ughh i might just leave it how it is, maybe come back to it later after thinking about it a little longer

actually observe has a couple more problems aswell, they aren't fired on lazy state objects.
i thought i addressed this and fixed it, but apparently it's still happening
i'm thinking of just going back to Observers for now
maybe observe can make a come back in the future once i figure it out properly
-- ]]

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
