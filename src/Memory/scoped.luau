local package = script.Parent.Parent

local Types = require(package.Types)
local merge = require(package.Utility.merge)

local function scoped<A>(...: A): Types.Scope<A>
	local metatable = { __index = merge(false, {}, ...) }

	return setmetatable({}, metatable)
end

return scoped
