local package = script.Parent

local named = require(package.Utility.named)

local Symbols = {
	named = named,
	DebugId = named 'DebugId',
	Scope = named 'Scope',

	Type = named 'Type',
	Kind = named 'Kind',
	InternalValue = named 'InternalValue',

	Validity = named 'Validity',
	LastChange = named 'LastChange',
	CreatedAt = named 'CreatedAt',
	Users = named 'Users',
	Using = named 'Using',
}

return Symbols
