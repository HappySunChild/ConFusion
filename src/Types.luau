--!strict

export type Error = {
	type: "Error",
	raw: string,
	message: string,
	trace: string,
}

export type CleanupTask = Instance | RBXScriptConnection | () -> () | { CleanupTask }
export type Child = Instance | ((Instance) -> Instance?) | { Child } | StateObject<Child>

export type Validity = "busy" | "invalid" | "valid"
export type Timeliness = "lazy" | "eager"

export type Properties = { [SpecialKey<string> | string]: any }

export type Scope<T = any> = { CleanupTask } & T

export type UsedAs<V> = StateObject<V> | V
export type Use = <V>(target: StateObject<V>) -> V

type Disconnect = () -> ()

export type ScopedObject = {
	scope: Scope<unknown>?,
}

export type GraphObject = {
	type: string?,
	kind: string?,

	createdAt: number?,
	validity: Validity?,
	timeliness: Timeliness,

	_lastChange: number?,
	_lastCompute: number?,
	_users: { [GraphObject]: true },
	_using: { [GraphObject]: true },

	_evaluate: (GraphObject) -> boolean,
} & ScopedObject

export type StateObject<V> = {
	_internalValue: V,

	kind: "state",
	type: string,
} & GraphObject

-- An object which can listen for updates on another state object.
export type Observer = {
	type: "Observer",
	kind: "graph",

	onBind: (Observer, callback: () -> ()) -> () -> (),
	onChange: (Observer, callback: () -> ()) -> () -> (),
} & GraphObject

type ObserverConstructor = (scope: Scope<unknown>, subject: ObjectValue) -> Observer

-- A state object whose value can be set by the user at any time.
export type Value<T> = {
	type: "Value",
	timeliness: "lazy",

	set: (Value<T>, newValue: T) -> T,
	update: (Value<T>, predicate: (T) -> T) -> T,

	bindToInstanceProperty: (
		Value<T>,
		instance: Instance,
		property: string
	) -> Disconnect,
} & StateObject<T>

type ValueConstructor = <V>(scope: Scope<unknown>, initialValue: V?) -> Value<V>

-- A state object whose value is derived from other objects using a callback.
export type Computed<T> = {
	type: "Computed",
	timeliness: "eager",
} & StateObject<T>

type ComputedConstructor = <T, S>(
	scope: Scope<S>,
	processor: (Use, S) -> T
) -> Computed<T>

-- A state object which maps over keys and/or values in another table.
export type For<OK, OV> = {
	type: "For",
	timeliness: "lazy",
} & StateObject<{ [OK]: OV }>

type ForPairsConstructor = <S, IK, IV, OK, OV>(
	scope: Scope<S>,
	input: UsedAs<{ [IK]: IV }>,
	processor: (Use, S, key: IK, value: IV) -> (OK, OV)
) -> For<OK, OV>

type ForKeysConstructor = <S, IK, IV, OK>(
	scope: Scope<S>,
	input: UsedAs<{ [IK]: IV }>,
	processor: (Use, S, key: IK) -> OK
) -> For<OK, IV>

type ForValuesConstructor = <S, IK, IV, OV>(
	scope: Scope<S>,
	input: UsedAs<{ [IK]: IV }>,
	processor: (S, value: IV) -> OV
) -> For<IK, OV>

-- A state object that's similar to Computed, but is asynchronous.
export type Eventual<V> = {
	type: "Eventual",
	timeliness: "lazy",

	isPending: (Eventual<V>) -> boolean,
} & StateObject<V>

type EventualConstructor = <V>(
	scope: Scope<unknown>,
	processor: (Use, become: (V) -> ()) -> (),
	default: V?
) -> Eventual<V>

export type Timer = StateObject<number> & {
	type: "Timer",

	pause: (Timer) -> (),
	unpause: (Timer) -> (),
	reset: (Timer) -> (),
}

export type AnimationCurve<V> = (elapsed: number) -> (boolean, V)
export type CurveGenerator<V> = (start: V, goal: V) -> AnimationCurve<V>

-- A state object whose value can be animated with a AnimatedMover callback.
export type Animated<V> = {
	type: "Animated",
} & StateObject<V>

type AnimatedConstructor = <V>(
	scope: Scope<unknown>,
	goal: UsedAs<V>,
	mover: CurveGenerator<V>
) -> Animated<V>

type TweenConstructor = <V>(
	scope: Scope<unknown>,
	goal: UsedAs<V>,
	info: UsedAs<TweenInfo>
) -> Animated<V>

type SpringConstructor = <V>(
	scope: Scope<unknown>,
	goal: UsedAs<V>,
	speed: UsedAs<number>,
	damping: UsedAs<number>
) -> Animated<V>

export type Contextual<T> = {
	now: (Contextual<T>) -> T,
	executeWith: <T, R, A...>(Contextual<T>, (A...) -> R, A...) -> R,
}
type ContextualConstructor = <T>(default: T) -> Contextual<T>

export type SpecialKeyStage =
	"self"
	| "descendants"
	| "properties"
	| "ancestor"
	| "observer"
	| "last"

export type SpecialKey<T = string> = {
	type: T,
	kind: "key",
	stage: SpecialKeyStage,

	apply: (scope: Scope, instance: Instance, value: any) -> (),
}

export type ExternalProvider = {
	startScheduler: () -> (),
	stopScheduler: () -> (),

	logErrorNonFatal: (message: string) -> (),
	logWarn: (message: string) -> (),

	doTaskImmediate: (resume: (...unknown) -> (), ...unknown) -> thread?,
	doTaskDeferred: (resume: (...unknown) -> (), ...unknown) -> thread?,
	cancelTask: (thread) -> boolean,
}

export type ConFusion = {
	version: {
		major: number,
		minor: number,
	},

	-- Memory
	read scoped: <B, M>(base: B, methods: M?) -> Scope<B> & M,
	read deriveScope: <T, M>(existing: T, methods: M?) -> T & M,
	read innerScope: <T, M>(existing: T, methods: M?) -> T & M,
	read doCleanup: (CleanupTask) -> (),

	-- External
	read setProvider: (newProvider: ExternalProvider?) -> ExternalProvider?,

	-- Utility
	read Contextual: ContextualConstructor,
	read peek: <V>(value: UsedAs<V> | V) -> V,
	read map: <V, O>(value: StateObject<V>, callback: (V) -> O) -> Computed<O>,
	read flatten: <T>(use: Use, target: UsedAs<T>) -> T,

	-- Graph
	read Observer: ObserverConstructor,

	-- State
	read Eventual: EventualConstructor,
	read Computed: ComputedConstructor,
	read Value: ValueConstructor,

	read ForPairs: ForPairsConstructor,
	read ForKeys: ForKeysConstructor,
	read ForValues: ForValuesConstructor,

	read Timer: (scope: Scope) -> Timer,

	-- Animation
	read Animated: AnimatedConstructor,
	read Tween: TweenConstructor,
	read Spring: SpringConstructor,

	-- Instances
	read New: (
		scope: Scope,
		classNameOrTemplate: Instance | string
	) -> (props: Properties) -> Instance,
	read Hydrate: (scope: Scope, instance: Instance) -> (props: Properties) -> Instance,
	read WithChild: (
		scope: Scope,
		name: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,
	read WithChildOfClass: (
		scope: Scope,
		className: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,
	read WithDescendant: (
		scope: Scope,
		name: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,
	read WithDescendantOfClass: (
		scope: Scope,
		className: string
	) -> (props: Properties) -> (parent: Instance) -> Instance?,

	-- Instance Keys
	read Children: SpecialKey<"Children">,
	read OnStartup: SpecialKey<"OnStartup">,
	read OnRemoval: SpecialKey<"OnRemoval">,
	read Ref: SpecialKey<"Ref">,
	read Passthrough: SpecialKey<"Passthrough">,
	read Attribute: (attribute: string) -> SpecialKey<"Attribute">,
	read AttributeChange: (attribute: string) -> SpecialKey<"AttributeChange">,
	read AttributeOut: (attribute: string) -> SpecialKey<"AttributeOut">,
	read Tag: (tag: string) -> SpecialKey<"Tag">,
	read Out: (property: string) -> SpecialKey<"Out">,
	read OnChange: (property: string) -> SpecialKey<"OnChange">,
	read OnEvent: (event: string) -> SpecialKey<"OnEvent">,
}

return nil
