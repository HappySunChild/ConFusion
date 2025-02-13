local package = script.Parent.Parent

local merge = require(package.Utility.merge)

local function deriveScope<S>(existingScope: S, methods, ...): S
	local metatable = getmetatable(existingScope)

	if methods ~= nil then
		metatable = table.clone(metatable)
		metatable.__index = merge(true, {}, metatable.__index, merge(false, {}, methods, ...))
	end

	return setmetatable({}, metatable)
end

return deriveScope
