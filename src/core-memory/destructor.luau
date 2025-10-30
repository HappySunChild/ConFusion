local graph = require "../core-graph/types"

local nicknames = require "../core-logging/nicknames"

local function destroy(target: graph.GraphObject)
	target.scope = nil

	local using = target._using

	for dependency in using do
		dependency._users[target] = nil
		using[dependency] = nil
	end

	local users = target._users

	for user in users do
		user._using[target] = nil
		users[user] = nil
	end
end

local function destructor<T>(target: graph.GraphObject & T, auxiliary: (T) -> ()?)
	local function destruct()
		destroy(target)

		if auxiliary ~= nil then
			auxiliary(target)
		end

		nicknames[destruct] = nil
	end

	nicknames[destruct] = debug.info(2, "n") or "unknown"

	return destruct
end

return destructor
