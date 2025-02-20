--!strict

local package = script.Parent.Parent

local Types = require(package.Types)
local merge = require(package.Utility.merge)

local function scoped<B, M>(base: B, methods: M): Types.Scope<B> & M
	local metatable = { __index = merge(false, {}, base, methods) }

	return setmetatable({}, metatable)
end

return scoped
