local package = script.Parent.Parent

local Symbols = require(package.Symbols)

local function destroy(target)
	target[Symbols.Scope] = nil

	local using = target[Symbols.Using]

	if using then
		for dependency in using do
			dependency[Symbols.Users][target] = nil
			target[Symbols.Using][dependency] = nil
		end
	end

	local users = target[Symbols.Users]

	if users then
		for user in users do
			user[Symbols.Using][target] = nil
			target[Symbols.Users][user] = nil
		end
	end
end

local function destructor(target)
	return function()
		destroy(target)
	end
end

return destructor
