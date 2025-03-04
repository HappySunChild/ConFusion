--!strict

local package = script.Parent.Parent

local Types = require(package.Types)
local kindof = require(package.Utility.kindOf)

local function castToState<T>(target: Types.UsedAs<T>): Types.StateObject<T>?
	if kindof(target) == "state" then
		return target
	end

	return nil
end

return castToState
