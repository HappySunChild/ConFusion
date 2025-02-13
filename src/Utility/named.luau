local function named(name: string, symbolType: string?)
	symbolType = symbolType or 'Symbol'

	return `<{symbolType} '{name}'>`
end

return named
