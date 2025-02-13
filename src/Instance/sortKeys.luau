local package = script.Parent.Parent

local Types = require(package.Types)

local keyOrder = {
	[Types.Cleanup] = 0,
	[Types.Event] = 1,
	[Types.Ref] = 5,
	[Types.Out] = 10,
	[Types.Children] = 50,
	[Types.Startup] = 100,
}

local function sortKeys(a, b)
	return keyOrder[Types.of(a)] < keyOrder[Types.of(b)]
end

return sortKeys
