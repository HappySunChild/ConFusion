local SpecialKey = require "./SpecialKey"

return SpecialKey "last" {
	name = "OnStartup",
	apply = function(_, apply_to: Instance, callback: (Instance) -> ())
		callback(apply_to)
	end,
}
