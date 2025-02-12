local package = script.Parent.Parent

local External = require(package.External)
local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local getTweenAlpha = require(package.Animation.getTweenAlpha)
local getTweenDuration = require(package.Animation.getTweenDuration)
local lerp = require(package.Animation.lerp)

local Computed = require(script.Parent.Computed)
local Observer = require(package.Graph.Observer)

local change = require(script.Parent.change)
local isSimilar = require(package.Utility.isSimilar)
local peek = require(script.Parent.peek)

local Tween = Symbols.named 'Tween'

local ValueClass = {
	[Symbols.Kind] = Kinds.State,
	[Symbols.Type] = Types.Value,
	[Symbols.Using] = table.freeze {},
}

local METATABLE = table.freeze { __index = ValueClass }

local function Value<V>(initialValue: V, debugId): Types.Value<V>
	local newValue = setmetatable({
		[Symbols.CreatedAt] = os.clock(),

		[Symbols.Internal] = initialValue,
		[Symbols.DebugId] = debugId,

		[Symbols.Users] = {},

		[Tween] = nil,
	}, METATABLE)

	return newValue
end

function ValueClass:onChange(callback)
	local observer = Observer(self)

	return observer:onChange(callback), observer
end

function ValueClass:set(newValue: any)
	local currentValue = self[Symbols.Internal]

	self[Symbols.Internal] = newValue

	if not isSimilar(newValue, currentValue) then
		change(self)
	end

	return newValue
end

function ValueClass:update(predicate)
	local currentValue = self[Symbols.Internal]

	return self:set(predicate(currentValue))
end

--- Tweens the value smoothly to the target value.
--- This function is useful for when you need to tween a value once.
---
--- Cancels any active tweens.
function ValueClass:tween(targetValue: Types.UsedAs<any>, info: Types.UsedAs<TweenInfo>, completedCallback: () -> nil)
	info = peek(info)
	targetValue = peek(targetValue)

	if self[Tween] then
		self[Tween]()
		self[Tween] = nil
	end

	local startValue = self[Symbols.Internal]

	if targetValue == startValue then
		return
	end

	local duration = getTweenDuration(info)
	local startTime = os.clock()

	local cancel = External.bind(function(now, disconnect)
		local elapsed = now - startTime
		local alpha = getTweenAlpha(info, elapsed)

		local newValue = lerp(startValue, targetValue, alpha)

		self:set(newValue)

		if elapsed >= duration then
			self[Tween] = nil
			disconnect()

			if completedCallback then
				completedCallback()
			end
		end
	end)

	self[Tween] = cancel

	return cancel
end

function ValueClass:map(processor)
	return Computed(function(use)
		return processor(use(self))
	end, `Computed({self[Symbols.DebugId]})`)
end

function ValueClass:bindToInstanceProperty(instance: Instance, property: string)
	local success = pcall(function()
		return instance[property]
	end)

	if not success then
		error(`'{property}' is not a valid property of instance '{instance}'`, 2)
	end

	self:set(instance[property])

	local connection = instance:GetPropertyChangedSignal(property):Connect(function()
		self:set(instance[property])
	end)

	return function()
		connection:Disconnect()
	end, connection
end

function ValueClass:_evaluate()
	return true
end

table.freeze(ValueClass)

return Value
