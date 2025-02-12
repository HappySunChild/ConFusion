local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Types = require(package.Types)

return function(element)
	local compType = Types.of(element.component)

	if compType == 'string' then
		return Kinds.Host
	elseif compType == 'function' then
		return Kinds.Function
	elseif compType == 'Instance' then
		return Kinds.Hydration
	elseif compType == Types.StatefulComponent then
		return Kinds.Stateful
	elseif Types.of(element) == Types.Fragment then
		return Kinds.Fragment
	end
end
