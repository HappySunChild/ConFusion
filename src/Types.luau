type NilFunc = () -> ()
type Disconnect = NilFunc
type GenericTable<K = any, V = any> = { [K]: V }

export type Properties = GenericTable<SpecialKey|string, any>

export type Task =
	Instance
	| RBXScriptConnection
	| () -> ()
	| { destroy: (any) -> () }
	| { Destroy: (any) -> () }
	| { Task }
export type Scope<Constructors = any> = { Task } & Constructors
export type Child = Instance | { Child } | UsedAs<Child>

export type Observer<V> = {
	onChange: (callback: (new: V) -> nil) -> Disconnect,
}

export type UsedAs<V> = StateObject<V> | V
export type StateObject<V> = {
	onChange: (StateObject<V>, callback: (new: V) -> nil) -> (Disconnect, Observer<V>),
}

export type Use = <V>(target: StateObject<V>) -> V
export type ComputedProcessor<T> = (Use) -> T
export type Computed<IV, OV> = StateObject<OV> & {
	map: <T>(Computed<IV, OV>, processor: (IV) -> T) -> Computed<T, T>,
}

export type Value<V> = StateObject<V> & {
	set: (Value<V>, newValue: V) -> V,
	update: (Value<V>, predicate: (V) -> V) -> V,
	map: <T>(Value<V>, processor: (V) -> T) -> Computed<T, T>,

	bindToInstanceProperty: (Value<V>, instance: Instance, property: string) -> (Disconnect, RBXScriptConnection),
}

export type Table<K, V> = StateObject<GenericTable<K, V>> & {
	setKey: (Table<K, V>, key: K, value: V) -> V,
	getKey: (Table<K, V>, key: K) -> V,
	
	insert: (Table<K, V>, index: number, value: V) -> V,
	remove: (Table<K, V>, index: number) -> V,
	
	map: <T>(Table<K, V>, processor: (GenericTable<K, V>) -> T) -> Computed<GenericTable<K, V>, T>,
}

export type ForPairs<IK, IV, OK, OV> = StateObject<GenericTable<OK, OV>>
export type Tween<V> = StateObject<V>

export type SpecialKey = {
	apply: (scope: Scope, instance: Instance, value: any) -> ()
}


local Symbols = require(script.Parent.Symbols)

local function createType(name: string)
	return Symbols.named(name, 'Type')
end

local Types = {
	Children = createType 'Children',
	Event = createType 'Event',
	Out = createType 'Out',
	Ref = createType 'Ref',
	Startup = createType 'Startup',
	Cleanup = createType 'Cleanup',

	Stopwatch = createType 'Stopwatch',

	Tween = createType 'Tween',
	Table = createType 'Table',
	Value = createType 'Value',
	Computed = createType 'Computed',
	For = createType 'For',

	Disassembly = createType 'Disassembly',

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
