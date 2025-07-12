local Types = require "../Types"

local destructor = require "../Memory/destructor"

local change = require "../Graph/change"

local class = table.freeze {
	type = "Attribute",
	kind = "state",
	timeliness = "lazy",
	_using = table.freeze {},

	_evaluate = function()
		return true
	end,
}
local METATABLE = table.freeze { __index = class }

local function AttributeOf(scope: Types.Scope, instance: Instance, attribute: string)
	local event = instance:GetAttributeChangedSignal(attribute)

	local newProperty = setmetatable({
		scope = scope,
		createdAt = os.clock(),

		_users = {},

		_internalValue = instance:GetAttribute(attribute),
	}, METATABLE)

	table.insert(scope, {
		destructor(newProperty),
		event:Connect(function()
			newProperty._internalValue = instance:GetAttribute(attribute)

			change(newProperty)
		end),
	})

	return newProperty
end

return AttributeOf
