local package = script.Parent.Parent.Parent

local xtypeof = require(package.Utility.xtypeof)

local keyOrder = table.freeze {
	"Ref",

	"Attribute",
	"Tag",

	"OnEvent",
	"OnChange",

	"Children",
	"Parent",

	"Cleanup",
	"Startup",
	"Out",

	"Apply",
}

local function sortKeys(a, b)
	local aIndex = table.find(keyOrder, xtypeof(a))
	local bIndex = table.find(keyOrder, xtypeof(b))

	return aIndex < bIndex
end

return sortKeys
