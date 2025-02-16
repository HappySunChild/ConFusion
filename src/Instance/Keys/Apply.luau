local package = script.Parent.Parent.Parent

local Types = require(package.Types)
local applyProperties = require(package.Instance.applyProperties)

local Apply: Types.SpecialKey = table.freeze {
	kind = 'key',
	type = 'apply',

	apply = applyProperties,
}

return Apply
