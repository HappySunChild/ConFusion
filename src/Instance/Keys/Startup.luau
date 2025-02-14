local package = script.Parent.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Startup: Types.SpecialKey = table.freeze {
	[Symbols.Kind] = 'key',
	[Symbols.Type] = 'startup',

	apply = function(_: Types.Scope, parent: Instance, callback)
		callback(parent)
	end,
}

return Startup
