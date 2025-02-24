local package = script.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local Computed = require(package.State.Computed)

local change = require(package.Graph.change)
local observe = require(package.Graph.observe)

local destructor = require(package.Memory.destructor)

local isSimilar = require(package.Utility.isSimilar)

type Self<V> = Types.Value<V>

local class = {
	kind = "state",
	type = "value",
	_using = table.freeze {},
}

local METATABLE = table.freeze { __index = class }

local function Value<V>(scope: Types.Scope, initialValue: V): Types.Value<V>
	local newValue = setmetatable({
		scope = scope,
		_createdAt = os.clock(),

		_internalValue = initialValue,

		_users = {},
	}, METATABLE) :: Self<V>

	table.insert(scope, destructor(newValue))

	return newValue
end

function class.map<V>(self: Self<V>, processor: (V) -> any)
	return Computed(self.scope, function(use)
		return processor(use(self))
	end)
end

function class.onChange<V>(self: Self<V>, callback)
	return observe(self, callback)
end

function class.set<V>(self: Self<V>, newValue: any)
	local currentValue = self._internalValue

	self._internalValue = newValue

	if not isSimilar(newValue, currentValue) then
		change(self)
	end

	return newValue
end

function class.bindToInstanceProperty<V>(self: Self<V>, instance: Instance, property: string)
	local ok, event: RBXScriptSignal =
		pcall(instance.GetPropertyChangedSignal, instance, property)

	if not ok or typeof(event) ~= "RBXScriptSignal" then
		External.logError("cannotConnectChange", nil, instance.ClassName, property)
	end

	self:set((instance :: any)[property])

	local connection = event:Connect(function()
		self:set((instance :: any)[property])
	end)

	table.insert(self.scope, connection)

	return function()
		connection:Disconnect()
	end
end

function class.update<V>(self: Self<V>, predicate)
	local currentValue = self._internalValue

	return self:set(predicate(currentValue))
end

function class._evaluate()
	return true
end

table.freeze(class)

return Value
