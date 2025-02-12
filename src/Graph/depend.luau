local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local evaluate = require(script.Parent.evaluate)

local function depend(user, dependency)
	evaluate(dependency)

	user[Symbols.Using][dependency] = true
	dependency[Symbols.Users][user] = true
end

return depend
