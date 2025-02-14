local package = script.Parent.Parent

local Symbols = require(package.Symbols)

local function kindOf(value: any): string
	local vType = typeof(value)

	if vType == 'table' then
		if value[Symbols.Kind] then
			return value[Symbols.Kind]
		end
	end

	return vType
end

return kindOf
