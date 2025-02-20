local package = script.Parent.Parent

local External = require(package.External)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Computed = require(package.State.Computed)

local change = require(package.Graph.change)
local destructor = require(package.Memory.destructor)
local isSimilar = require(package.Utility.isSimilar)
local observe = require(package.Graph.observe)

local class = {
	kind = "state",
	type = "value",
	[Symbols.Using] = table.freeze {},
}

local METATABLE = table.freeze { __index = class }

local function Value<V>(scope: Types.Scope, initialValue: V): Types.Value<V>
	local newValue = setmetatable({
		[Symbols.Scope] = scope,
		[Symbols.CreatedAt] = os.clock(),

		[Symbols.InternalValue] = initialValue,

		[Symbols.Users] = {},
	}, METATABLE)

	table.insert(scope, destructor(newValue))

	return newValue
end

function class:map(processor)
	return Computed(self[Symbols.Scope], function(use)
		return processor(use(self))
	end)
end

function class:onChange(callback)
	return observe(self, callback)
end

function class:set(newValue: any)
	local currentValue = self[Symbols.InternalValue]

	self[Symbols.InternalValue] = newValue

	if not isSimilar(newValue, currentValue) then
		change(self)
	end

	return newValue
end

function class:bindToInstanceProperty(instance: Instance, property: string)
	local ok, event: RBXScriptSignal =
		pcall(instance.GetStyledPropertyChangedSignal, instance, property)

	if not ok or typeof(event) ~= "RBXScriptSignal" then
		External.logError("cannotConnectChange", nil, instance.ClassName, property)
	end

	self:set(instance[property])

	local scope = self[Symbols.Scope]
	local connection = event:Connect(function()
		self:set(instance[property])
	end)

	table.insert(scope, connection)

	return function()
		connection:Disconnect()
	end
end

function class:update(predicate)
	local currentValue = self[Symbols.InternalValue]

	return self:set(predicate(currentValue))
end

function class:_evaluate()
	return true
end

table.freeze(class)

return Value
