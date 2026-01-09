local instances = require "./types"
local memory = require "../core-memory/types"

local change = require "../core-graph/change"

local destroy_node = require "../core-memory/destroy_node"

type Self<T> = {
	_event: RBXScriptConnection,
} & instances.AttributeOf<T>

local CLASS = table.freeze {
	type = "State",
	kind = "AttributeOf",
	timeliness = "lazy",
	_using = table.freeze {},

	_evaluate = function()
		return true
	end,
	destroy = function<T>(self: Self<T>)
		self._event:Disconnect()

		destroy_node(self)
	end,
}
local METATABLE = table.freeze { __index = CLASS }

local function AttributeOf<T>(
	scope: memory.Scope,
	instance: Instance,
	attribute: string
): instances.AttributeOf<T>
	local event = instance:GetAttributeChangedSignal(attribute)

	local new_attribute: Self<T> = setmetatable({
		scope = scope,
		created_at = os.clock(),

		_users = {},

		_internal_value = instance:GetAttribute(attribute),
		_event = nil,
	}, METATABLE) :: any

	new_attribute._event = event:Connect(function()
		new_attribute._internal_value = instance:GetAttribute(attribute)

		change(new_attribute)
	end)

	table.insert(scope, new_attribute)

	return new_attribute
end

return AttributeOf
