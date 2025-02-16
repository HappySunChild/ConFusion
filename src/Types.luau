--!strict

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
	onChange: (Observer<V>, callback: (new: V) -> nil) -> Disconnect,
	onBind: (Observer<V>, callback: (new: V) -> nil) -> Disconnect,
}

export type UsedAs<V> = StateObject<V> | V
export type StateObject<V> = {
	kind: 'state',
	type: string,
	
	onChange: (StateObject<V>, callback: (new: V) -> nil) -> (Disconnect, Observer<V>),
}

export type Use = <V>(target: StateObject<V>) -> V
export type ComputedProcessor<T> = (Use) -> T
export type Computed<IV, OV> = StateObject<OV> & {
	type: 'computed',
	
	map: <T>(Computed<IV, OV>, processor: (IV) -> T) -> Computed<T, T>,
}

export type Value<V> = StateObject<V> & {
	type: 'value',
	
	set: (Value<V>, newValue: V) -> V,
	update: (Value<V>, predicate: (V) -> V) -> V,
	map: <T>(Value<V>, processor: (V) -> T) -> Computed<T, T>,

	bindToInstanceProperty: (Value<V>, instance: Instance, property: string) -> (Disconnect, RBXScriptConnection),
}

export type Table<K, V> = StateObject<GenericTable<K, V>> & {
	type: 'table',
	
	setKey: (Table<K, V>, key: K, value: V) -> V,
	getKey: (Table<K, V>, key: K) -> V,
	
	insert: (Table<K, V>, index: number, value: V) -> V,
	remove: (Table<K, V>, index: number) -> V,
	
	map: <T>(Table<K, V>, processor: (GenericTable<K, V>) -> T) -> Computed<GenericTable<K, V>, T>,
}

export type ForPairs<IK, IV, OK, OV> = StateObject<GenericTable<OK, OV>> & {
	type: 'for'
}

export type Tween<V> = StateObject<V> & {
	type: 'tween'
}

export type Spring<V> = StateObject<V> & {
	type: 'spring',
	animating: boolean
}

export type SpecialKey = {
	apply: (scope: Scope, instance: Instance, value: any) -> ()
}

export type ExternalProvider = {
	startScheduler: () -> (),
	stopScheduler: () -> (),
	
	logErrorNonFatal: (message: string) -> (),
	logWarn: (message: string) -> (),
	
	doTaskImmediate: (resume: (...any) -> (), ...any) -> (),
	doTaskDeferred: (resume: (...any) -> (), ...any) -> (),
}

export type Error = {
	type: 'Error',
	raw: string,
	message: string,
	trace: string
}

return nil
