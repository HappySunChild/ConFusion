--[[
package: confusion-for-roblox

ConFusion - A fork of Fusion

GitHub Repository: https://github.com/HappySunChild/ConFusion
Fusion on GitHub: https://github.com/dphfox/Fusion
--]]

local calc = require "@self/core-calc/types"
local graph = require "@self/core-graph/types"
local memory = require "@self/core-memory/types"

local iter = require "@self/calc-iter/types"

local async = require "@self/async/types"
local chrono = require "@self/chrono/types"
local context = require "@self/context/types"
local pipeline = require "@self/pipeline/types"

local motion = require "@self/motion/types"
local springs = require "@self/motion-springs/types"
local tweens = require "@self/motion-tweens/types"

local binds = require "@self/roblox-binds/types"
local instances = require "@self/roblox-instances/types"
local stylesheets = require "@self/roblox-stylesheets/types"
local templates = require "@self/roblox-templates/types"

export type Scope<T = ConFusion> = memory.Scope<T>

export type GraphObject = graph.GraphObject

export type StateObject<T> = calc.StateObject<T>
export type Value<V> = calc.Value<V>
export type Computed<V> = calc.Computed<V>
export type Use = calc.Use
export type UsedAs<T> = calc.UsedAs<T>

export type For<OK, OV> = iter.For<OK, OV>

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

	-- Core: Memory
	read scoped: <B, M>(base: B, methods: M?) -> memory.Scope<B> & M,
	read deriveScope: <T, M>(existing: T, methods: M?) -> T & M,
	read innerScope: <T, M>(existing: T, methods: M?) -> T & M,
	read doCleanup: (action: memory.CleanupTask) -> (),
	read insert: <Tasks...>(scope: memory.Scope, Tasks...) -> Tasks...,

	-- Core: State
	read Computed: calc.ComputedConstructor,
	read Value: calc.ValueConstructor,

	-- Core: Graph
	read observe: (
		scope: memory.Scope,
		subject: graph.GraphObject,
		callback: () -> (),
		immediate: boolean?
	) -> () -> (),

	-- Core: Use
	read peek: calc.Use,
	read flatten: <T>(calc.Use, calc.UsedAs<T>) -> T,

	-- Calc: Iter
	read ForPairs: iter.ForPairsConstructor,
	read ForKeys: iter.ForKeysConstructor,
	read ForValue: iter.ForValuesConstructor,

	-- Async
	read Eventual: async.EventualConstructor,
	read await: (subject: graph.GraphObject) -> (),

	-- Context
	read Contextual: context.ContextConstructor,

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

	-- Roblox: Stylesheets
	read StyleRule: stylesheets.StyleRuleConstructor,
	read StyleSheet: stylesheets.StyleSheetConstructor,

	read Default: instances.SpecialKey<"Default">,
	read StyleDerives: instances.SpecialKey<"StyleDerives">,
	read StyleRules: instances.SpecialKey<"StyleRules">,
	read StyleProperties: instances.SpecialKey<"StyleProperties">,
	read StyleLink: instances.SpecialKey<"StyleLink">,

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

local External = require "@self/core-external/External"

local RobloxProvider = require "@self/roblox-provider/RobloxProvider"
External.setProvider(RobloxProvider)

local ConFusion = table.freeze {
	version = table.freeze {
		major = 0,
		minor = 4,
	},

	-- Core: Memory
	scoped = require "@self/core-memory/scoped",
	deriveScope = require "@self/core-memory/deriveScope",
	innerScope = require "@self/core-memory/innerScope",
	doCleanup = require "@self/core-memory/doCleanup",
	insert = require "@self/core-memory/insert",

	-- Core: State
	Computed = require "@self/core-calc/Computed",
	Value = require "@self/core-calc/Value",

	-- Core: Graph
	observe = require "@self/core-graph/observe",

	-- Core: Use
	peek = require "@self/core-use/peek",
	flatten = require "@self/core-use/flatten",

	-- Calc: Iter
	ForPairs = require "@self/calc-iter/ForPairs",
	ForKeys = require "@self/calc-iter/ForKeys",
	ForValues = require "@self/calc-iter/ForValues",

	-- Async
	Eventual = require "@self/async/Eventual",
	await = require "@self/async/await",

	-- Context
	Contextual = require "@self/context/Contextual",

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

	-- Roblox: Stylesheets
	StyleRule = require "@self/roblox-stylesheets/StyleRule",
	StyleSheet = require "@self/roblox-stylesheets/StyleSheet",

	Default = require "@self/roblox-stylesheets/keys/Default",
	StyleDerives = require "@self/roblox-stylesheets/keys/StyleDerives",
	StyleRules = require "@self/roblox-stylesheets/keys/StyleRules",
	StyleProperties = require "@self/roblox-stylesheets/keys/StyleProperties",
	StyleLink = require "@self/roblox-stylesheets/keys/StyleLink",

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
