local Symbols = require(script.Parent.Symbols)

local function createKind(name: string)
	return Symbols.named(name, 'Kind')
end

local Kinds = {
	State = createKind 'State',
	Graph = createKind 'Graph',
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
