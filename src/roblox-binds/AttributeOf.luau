local instances = require "./types"
local memory = require "../core-memory/types"

local change = require "../core-graph/change"
local destructor = require "../core-memory/destructor"

local CLASS = table.freeze {
	type = "AttributeOf",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},

	_evaluate = function()
		return true
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function AttributeOf(
	scope: memory.Scope,
	instance: Instance,
	attribute: string
): instances.AttributeOf<unknown>
	local event = instance:GetAttributeChangedSignal(attribute)

	local new_attribute: instances.AttributeOf<unknown> = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},

		_internvalValue = instance:GetAttribute(attribute),
	}, METATABLE) :: any

	table.insert(scope, {
		destructor(new_attribute),
		event:Connect(function()
			new_attribute._internalValue = instance:GetAttribute(attribute)

			change(new_attribute)
		end),
	})

	return new_attribute
end

return AttributeOf
