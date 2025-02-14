local package = script.Parent.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)
local applyProperties = require(package.Instance.applyProperties)

local Apply: Types.SpecialKey = table.freeze {
	[Symbols.Kind] = 'key',
	[Symbols.Type] = 'apply',

	apply = applyProperties,
}

return Apply
