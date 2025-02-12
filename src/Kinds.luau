local Symbols = require(script.Parent.Symbols)

local function createKind(name)
	local newSymbol = newproxy(true)

	getmetatable(newSymbol).__tostring = function()
		return `<Kind '{name}'>`
	end

	return newSymbol
end

local Kinds = {
	State = createKind 'State',
	Key = createKind 'Key',
}

function Kinds.of(value)
	local vType = type(value)

	if vType == 'table' then
		if value[Symbols.Kind] then
			return value[Symbols.Kind]
		end
	end

	return vType
end

return Kinds
