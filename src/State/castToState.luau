local package = script.Parent.Parent

local Kinds = require(package.Kinds)

local function castToState(target)
	if Kinds.of(target) == Kinds.State then
		return target
	end

	return nil
end

return castToState
