local package = script.Parent.Parent

local Symbols = require(package.Symbols)

local function typeOf(value: any): string
	local vType = typeof(value)

	if vType == 'table' then
		if value[Symbols.Type] then
			return value[Symbols.Type]
		end
	end

	return vType
end

return typeOf
