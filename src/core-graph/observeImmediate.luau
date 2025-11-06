local graph = require "./types"
local memory = require "../core-memory/types"

local External = require "../core-external/External"
local observe = require "./observe"

local function observeImmediate(
	scope: memory.Scope,
	subject: graph.GraphObject,
	callback: () -> ()
): () -> ()
	External.doTaskImmediate(callback)

	return observe(scope, subject, callback)
end

return observeImmediate
