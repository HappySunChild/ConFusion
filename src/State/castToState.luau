--!strict

local package = script.Parent.Parent

local kindof = require(package.Utility.kindOf)

local function castToState(target)
	if kindof(target) == 'state' then
		return target
	end

	return nil
end

return castToState
