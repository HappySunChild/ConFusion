local package = script.Parent.Parent

local Types = require(package.Types)
local merge = require(package.Utility.merge)

local function deriveScope(existing: Types.Scope, methods: { [unknown]: unknown }): unknown
	local metatable = getmetatable(existing)

	if methods ~= nil then
		metatable = table.clone(metatable)
		metatable.__index = merge(true, {}, metatable.__index, merge(false, {}, methods))
	end

	return setmetatable({}, metatable)
end

return deriveScope :: <T, M>(existing: T, methods: M) -> T & M
