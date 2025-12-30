local instances = require "./types"
local memory = require "../core-memory/types"

local change = require "../core-graph/change"

local generic_destroy = require "../core-memory/generic_destroy"

type Self<T> = instances.AttributeOf<T> & {
	_event: RBXScriptConnection,
}

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

		generic_destroy(self)
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
