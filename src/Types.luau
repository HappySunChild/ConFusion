--!strict

type Disconnect = () -> ()

export type Properties = { [SpecialKey | string]: any }

export type Task =
	Instance
	| RBXScriptConnection
	| () -> ()
	| { destroy: (any) -> () }
	| { Destroy: (any) -> () }
	| { Task }
export type Scope<T = unknown> = { Task } & T
export type Child = Instance | ((Instance) -> Instance?) | { Child } | UsedAs<Child>

export type Error = {
	type: "Error",
	raw: string,
	message: string,
	trace: string,
}

export type UsedAs<V> = StateObject<V> | V

export type ScopedObject = {
	scope: Scope<unknown>,
}

export type GraphObject = ScopedObject & {
	_createdAt: number?,
	_lastChange: number?,
	_validity: string?,
	_users: { [GraphObject]: unknown },
	_using: { [GraphObject]: unknown },
	_evaluate: (GraphObject) -> boolean,
}

export type StateObject<V> = GraphObject & {
	_internalValue: V,
	kind: "state",
	type: string,

	onChange: (StateObject<V>, callback: (new: V) -> nil) -> Disconnect,
}

export type Use = <V>(target: StateObject<V>) -> V

export type Computed<IV, OV> = StateObject<OV> & {
	type: "computed",
	_processor: (Use) -> OV,

	map: <T>(Computed<IV, OV>, processor: (IV) -> T) -> Computed<T, T>,
}

export type Value<V> = StateObject<V> & {
	type: "value",

	set: (Value<V>, newValue: V) -> V,
	update: (Value<V>, predicate: (V) -> V) -> V,
	map: <T>(Value<V>, processor: (V) -> T) -> Computed<T, T>,

	bindToInstanceProperty: (
		Value<V>,
		instance: Instance,
		property: string
	) -> Disconnect,
}

export type Table<K, V> = StateObject<{ [K]: V }> & {
	type: "table",

	setKey: (Table<K, V>, key: K, value: V) -> V,
	getKey: (Table<K, V>, key: K) -> V,

	insert: (Table<K, V>, index: number, value: V) -> V,
	remove: (Table<K, V>, index: number) -> V,

	map: <T>(Table<K, V>, processor: ({ [K]: V }) -> T) -> Computed<{ [K]: V }, T>,
}

export type For<IK, IV, OK, OV> = StateObject<{ [OK]: OV }> & {
	type: "for",
}

export type Animated<V> = StateObject<V> & {
	type: "animated",
	status: boolean,

	bindStatusChange: (Animated<V>, callback: (active: boolean) -> ()) -> Disconnect,
}

export type SpecialKey = {
	type: string,
	kind: "key",
	apply: (scope: Scope, instance: Instance, value: any) -> (),
}

export type ExternalProvider = {
	startScheduler: () -> (),
	stopScheduler: () -> (),

	logErrorNonFatal: (message: string) -> (),
	logWarn: (message: string) -> (),

	doTaskImmediate: (resume: (...unknown) -> (), ...unknown) -> (),
	doTaskDeferred: (resume: (...unknown) -> (), ...unknown) -> (),
}

return nil
