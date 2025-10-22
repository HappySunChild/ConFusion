--[[
package: confusion-for-roblox

ConFusion - A fork of Fusion

GitHub Repository: https://github.com/HappySunChild/ConFusion
Fusion on GitHub: https://github.com/dphfox/Fusion
--]]

local async = require "@self/async/types"
local calc = require "@self/calc/types"
local chrono = require "@self/chrono/types"
local context = require "@self/context/types"
local graph = require "@self/graph/types"
local memory = require "@self/memory/types"
local pipeline = require "@self/pipeline/types"

local motion = require "@self/motion/types"
local springs = require "@self/motion-springs/types"
local tweens = require "@self/motion-tweens/types"

local binds = require "@self/roblox-binds/types"
local instances = require "@self/roblox-instances/types"
local templates = require "@self/roblox-templates/types"

export type Scope<T = ConFusion> = memory.Scope<T>

export type GraphObject = graph.GraphObject

export type StateObject<T> = calc.StateObject<T>
export type Value<V> = calc.Value<V>
export type Computed<V> = calc.Computed<V>
export type For<OK, OV> = calc.For<OK, OV>
export type Use = calc.Use
export type UsedAs<T> = calc.UsedAs<T>

export type Animated<T> = motion.Animated<T>
export type TweenInfo = tweens.TweenInfo

export type Eventual<T> = async.Eventual<T>

export type Contextual<T> = context.Contextual<T>

export type Timer = chrono.Timer

export type Pipe<T, S = unknown> = pipeline.Pipe<S, T>

export type SpecialKey<T = string> = instances.SpecialKey
export type Child = instances.Child

type ConFusion = {
	read version: {
		read major: number,
		read minor: number,
	},

	-- Memory
	read scoped: <B, M>(base: B, methods: M?) -> memory.Scope<B> & M,
	read deriveScope: <T, M>(existing: T, methods: M?) -> T & M,
	read innerScope: <T, M>(existing: T, methods: M?) -> T & M,
	read doCleanup: (action: memory.CleanupTask) -> (),
	read insert: <Tasks...>(scope: memory.Scope, Tasks...) -> Tasks...,

	-- State/Calculated State
	read Computed: calc.ComputedConstructor,
	read Value: calc.ValueConstructor,
	read ForPairs: calc.ForPairsConstructor,
	read ForKeys: calc.ForKeysConstructor,
	read ForValue: calc.ForValuesConstructor,

	-- Async
	read Eventual: async.EventualConstructor,
	read await: (subject: graph.GraphObject) -> (),

	-- Contextual
	read Contextual: context.ContextConstructor,

	-- Use
	read peek: calc.Use,
	read flatten: <T>(calc.Use, calc.UsedAs<T>) -> T,

	-- Graph
	read observe: (
		scope: memory.Scope,
		subject: graph.GraphObject,
		callback: () -> (),
		immediate: boolean?
	) -> () -> (),

	-- Chrono
	read Timer: chrono.TimerConstructor,

	-- Safe
	read Safe: <Ok, Err>(callbacks: { try: () -> Ok, fallback: () -> Err }) -> Ok | Err,

	-- Motion
	read Animated: motion.AnimatedConstructor,

	-- Motion: Springs
	read Spring: springs.SpringConstructor,

	-- Motion: Tweens
	read Tween: tweens.TweenConstructor,
	read EasingStyles: tweens.EasingStyles,
	read TweenInfo: tweens.TweenInfoConstructor,

	-- Pipeline
	read Pipe: pipeline.PipeConstructor,

	-- Roblox: Instances
	read New: instances.NewConstructor,
	read Hydrate: instances.HydrateConstructor,

	read Children: instances.SpecialKey<"Children">,
	read OnStartup: instances.SpecialKey<"OnStartup">,
	read OnRemoval: instances.SpecialKey<"OnRemoval">,
	read Passthrough: instances.SpecialKey<"Passthrough">,
	read Ref: instances.SpecialKey<"Ref">,
	read Attribute: (attribute: string) -> instances.SpecialKey<"Attribute">,
	read AttributeChange: (attribute: string) -> instances.SpecialKey<"AttributeChange">,
	read AttributeOut: (attribute: string) -> instances.SpecialKey<"AttributeOut">,
	read Tag: (tag: string) -> instances.SpecialKey<"Tag">,
	read Out: (property: string) -> instances.SpecialKey<"Out">,
	read OnEvent: (event: string) -> instances.SpecialKey<"OnEvent">,
	read OnChange: (property: string) -> instances.SpecialKey<"OnChange">,

	-- Roblox: Templates
	read FromTemplate: templates.FromTemplateConstructor,
	read OfName: templates.WithChildConstructor,
	read OfClass: templates.WithChildOfClassConstructor,
	read DescendantOfName: templates.WithChildConstructor,
	read DescendantOfClass: templates.WithChildOfClassConstructor,

	-- Roblox: Binds
	read PropertyOf: binds.PropertyOfConstructor,
	read AttributeOf: binds.AttributeOfConstructor,
}

local External = require "@self/external/External"

local RobloxProvider = require "@self/roblox-provider/RobloxProvider"
External.setProvider(RobloxProvider)

local ConFusion = table.freeze {
	version = table.freeze {
		major = 0,
		minor = 4,
	},

	-- Memory
	scoped = require "@self/memory/scoped",
	deriveScope = require "@self/memory/deriveScope",
	innerScope = require "@self/memory/innerScope",
	doCleanup = require "@self/memory/doCleanup",
	insert = require "@self/memory/insert",

	-- State/Calculated State
	Computed = require "@self/calc/Computed",
	Value = require "@self/calc/Value",
	ForPairs = require "@self/calc/ForPairs",
	ForKeys = require "@self/calc/ForKeys",
	ForValues = require "@self/calc/ForValues",

	-- Async
	Eventual = require "@self/async/Eventual",
	await = require "@self/async/await",

	-- Context
	Contextual = require "@self/context/Contextual",

	-- Use
	peek = require "@self/use/peek",
	flatten = require "@self/use/flatten",

	-- Graph
	observe = require "@self/graph/observe",

	-- Chrono
	Timer = require "@self/chrono/Timer",

	-- Safe
	Safe = require "@self/safe/Safe",

	-- Motion
	Animated = require "@self/motion/Animated",

	-- Motion: Springs
	Spring = require "@self/motion-springs/Spring",

	-- Motion: Tweens
	Tween = require "@self/motion-tweens/Tween",
	TweenInfo = require "@self/motion-tweens/TweenInfo",
	EasingStyles = require "@self/motion-tweens/EasingStyles",

	-- Pipeline
	Pipe = require "@self/pipeline/Pipe",

	-- Roblox: Instances
	New = require "@self/roblox-instances/New",
	Hydrate = require "@self/roblox-instances/Hydrate",

	Children = require "@self/roblox-instances/keys/Children",
	OnStartup = require "@self/roblox-instances/keys/OnStartup",
	OnRemoval = require "@self/roblox-instances/keys/OnRemoval",
	Passthrough = require "@self/roblox-instances/keys/Passthrough",
	Ref = require "@self/roblox-instances/keys/Ref",
	Attribute = require "@self/roblox-instances/keys/Attribute",
	AttributeChange = require "@self/roblox-instances/keys/AttributeChange",
	AttributeOut = require "@self/roblox-instances/keys/AttributeOut",
	Tag = require "@self/roblox-instances/keys/Tag",
	Out = require "@self/roblox-instances/keys/Out",
	OnEvent = require "@self/roblox-instances/keys/OnEvent",
	OnChange = require "@self/roblox-instances/keys/OnChange",

	-- Roblox: Templates
	FromTemplate = require "@self/roblox-templates/FromTemplate",
	OfName = require "@self/roblox-templates/OfName",
	OfClass = require "@self/roblox-templates/OfClass",
	DescendantOfName = require "@self/roblox-templates/DescendantOfName",
	DescendantOfClass = require "@self/roblox-templates/DescendantOfClass",

	-- Roblox: Binds
	PropertyOf = require "@self/roblox-binds/PropertyOf",
	AttributeOf = require "@self/roblox-binds/AttributeOf",
}

return ConFusion :: ConFusion
