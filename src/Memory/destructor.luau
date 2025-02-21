local package = script.Parent.Parent

local Types = require(package.Types)

local function destroy<V>(target: Types.GraphObject)
	target.scope = nil
	target._observers = nil

	local using = target._using

	if using then
		for dependency in using do
			dependency._users[target] = nil
			using[dependency] = nil
		end
	end

	local users = target._users

	if users then
		for user in users do
			user._using[target] = nil
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
