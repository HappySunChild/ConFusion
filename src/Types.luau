export type NullFunc = () -> nil
export type Disconnect = NullFunc

export type Observer<V> = {
	onChange: (callback: (new: V) -> nil) -> Disconnect,
}

export type StateObject<V> = {
	onChange: (StateObject<V>, callback: (new: V) -> nil) -> (Disconnect, Observer<V>),
}

export type UsedAs<V> = StateObject<V> | V

export type Use = <V>(target: StateObject<V>) -> V
export type ComputedProcessor<T> = (Use) -> T

export type Computed<V, T> = StateObject<T> & {
	map: <T>(Value<V>, processor: (V) -> T) -> Computed<T, T>,
}

export type Value<V> = StateObject<V> & {
	set: (Value<V>, newValue: V) -> V,
	update: (Value<V>, predicate: (V) -> V) -> V,
	map: <T>(Value<V>, processor: (V) -> T) -> Computed<T, T>,

	tween: (Value<V>, target: UsedAs<V>, info: UsedAs<TweenInfo>, completedCallback: NullFunc?) -> Disconnect,
	bindToInstanceProperty: (Value<V>, instance: Instance, property: string) -> (Disconnect, RBXScriptConnection),
}

export type Properties = { any }

export type Ref = {
	set: (Ref, instance: Instance) -> nil,
	get: (Ref) -> Instance?,
}

local Symbols = require(script.Parent.Symbols)

local function createType(name)
	local newType = newproxy(true)

	getmetatable(newType).__tostring = function()
		return `<Type '{name}'>`
	end

	return newType
end

local Types = {
	Children = createType 'Children',
	Event = createType 'Event',
	Out = createType 'Out',

	Stopwatch = createType 'Stopwatch',

	Value = createType 'Value',
	Computed = createType 'Computed',
	Tween = createType 'Tween',

	Observer = createType 'Observer',
	Signal = createType 'Signal',
}

function Types.of(value)
	local vType = typeof(value)

	if vType == 'table' then
		if value[Symbols.Type] then
			return value[Symbols.Type]
		end
	end

	return vType
end

return Types
