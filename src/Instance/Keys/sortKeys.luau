local package = script.Parent.Parent.Parent

local typeof = require(package.Utility.typeOf)

local keyOrder = table.freeze {
	'ref',

	'attribute',
	'tag',

	'onEvent',
	'onChange',

	'children',
	'parent',

	'cleanup',
	'startup',
	'out',

	'apply',
}

local function sortKeys(a, b)
	local aIndex = table.find(keyOrder, typeof(a))
	local bIndex = table.find(keyOrder, typeof(b))

	return aIndex < bIndex
end

return sortKeys
