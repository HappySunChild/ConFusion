local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Startup: Types.SpecialKey = {
	[Symbols.Kind] = Kinds.Key,
	[Symbols.Type] = Types.Startup,

	apply = function(_: Types.Scope, parent: Instance, callback)
		callback(parent)
	end,
}

return Startup
