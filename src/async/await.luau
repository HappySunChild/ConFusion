local graph = require "../graph/types"

local observe = require "../graph/observe"

-- pauses the current thread until a change happens to the subject
local function await(subject: graph.GraphObject)
	local current = coroutine.running()

	local disconnect
	disconnect = observe(subject.scope, subject, function()
		coroutine.resume(current)

		disconnect()
	end)

	coroutine.yield()
end

return await
