local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local evaluate = require(package.Graph.evaluate)
local nameOf = require(package.Utility.nameOf)

local function depend(user: Types.GraphObject, dependency: Types.GraphObject)
	evaluate(dependency)

	if table.isfrozen(user._using) or table.isfrozen(dependency._users) then
		return External.logError(
			"cannotDepend",
			nil,
			nameOf(user, "User") .. (table.isfrozen(user._using) and " (FROZEN)" or ""),
			nameOf(dependency, "Dependency")
				.. (table.isfrozen(dependency._users) and " (FROZEN)" or "")
		)
	end

	user._using[dependency] = true
	dependency._users[user] = true

	return true
end

return depend
