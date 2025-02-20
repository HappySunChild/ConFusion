--!strict

local function named(name: string)
	return `_{name:lower()}`
end

local Symbols = {
	named = named,

	InternalValue = named 'InternalValue',
	Scope = named 'Scope',

	Validity = named 'Validity',
	LastChange = named 'LastChange',
	CreatedAt = named 'CreatedAt',
	Users = named 'Users',
	Using = named 'Using',
	Observers = named 'Observers',
}

return Symbols
