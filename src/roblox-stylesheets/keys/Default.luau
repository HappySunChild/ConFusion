local SpecialKey = require "../../roblox-instances/keys/SpecialKey"

return SpecialKey(
	"self",
	"Default",
	function(_, apply_to: Instance, properties: { string })
		for _, property in properties do
			apply_to:ResetPropertyToDefault(property)
		end
	end
)
