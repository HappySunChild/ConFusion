local package = script.Parent.Parent

local External = require(package.External)
local Symbols = require(package.Symbols)

local evaluate = require(package.Graph.evaluate)
local nameOf = require(package.Utility.nameOf)

local function depend(user, dependency)
	evaluate(dependency)

	if
		table.isfrozen(user[Symbols.Using]) or table.isfrozen(dependency[Symbols.Users])
	then
		return External.logError(
			'cannotDepend',
			nil,
			nameOf(user, 'User'),
			nameOf(dependency, 'Dependency')
		)
	end

	user[Symbols.Using][dependency] = true
	dependency[Symbols.Users][user] = true

	return true
end

return depend
