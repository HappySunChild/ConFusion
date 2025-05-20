local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local OnStartup = table.freeze {
	type = "OnStartup",
	kind = "key",
	stage = "last",

	apply = function(_: Types.Scope, parent: Instance, callback: (Instance) -> ())
		callback(parent)
	end,
} :: Types.SpecialKey<"OnStartup">

return OnStartup
