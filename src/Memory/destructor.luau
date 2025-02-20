local package = script.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local function destroy<V>(target: Types.StateObject<V>)
	target[Symbols.Scope] = nil
	target[Symbols.Observers] = nil

	local using = target[Symbols.Using]

	if using then
		for dependency in using do
			dependency[Symbols.Users][target] = nil
			using[dependency] = nil
		end
	end

	local users = target[Symbols.Users]

	if users then
		for user in users do
			user[Symbols.Using][target] = nil
			users[user] = nil
		end
	end
end

local function destructor(target)
	return function()
		destroy(target)
	end
end

return destructor
