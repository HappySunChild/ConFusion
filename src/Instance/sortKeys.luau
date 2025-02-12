local package = script.Parent.Parent

local Types = require(package.Types)

local keyOrder = {
	[Types.Event] = 0,
	[Types.Out] = 10,
	[Types.Children] = 100,
}

local function sortKeys(a, b)
	return keyOrder[Types.of(a)] < keyOrder[Types.of(b)]
end

return sortKeys
