local instances = require "./types"
local memory = require "../core-memory/types"

local change = require "../core-graph/change"

local destructor = require "../core-memory/destructor"

local CLASS = table.freeze {
	type = "State",
	kind = "AttributeOf",
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
		created_at = os.clock(),

		_users = {},

		_internal_value = instance:GetAttribute(attribute),
	}, METATABLE) :: any

	table.insert(scope, {
		destructor(new_attribute),
		event:Connect(function()
			new_attribute._internal_value = instance:GetAttribute(attribute)

			change(new_attribute)
		end),
	})

	return new_attribute
end

return AttributeOf
