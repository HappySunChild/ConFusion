--[[
package: confusion-for-roblox

ConFusion - A fork of Fusion

GitHub Repository: https://github.com/HappySunChild/ConFusion
Fusion on GitHub: https://github.com/dphfox/Fusion
--]]

local calc = require "@self/core-calc/types"
local graph = require "@self/core-graph/types"
local memory = require "@self/core-memory/types"
local use = require "@self/core-use/types"

local iter = require "@self/iter/types"
local iter_for = require "@self/iter-for/types"
local iter_range = require "@self/iter-range/types"

local async = require "@self/async/types"
local chrono = require "@self/chrono/types"
local context = require "@self/context/types"
local pipeline = require "@self/pipeline/types"
local safe = require "@self/safe/types"
local sequence = require "@self/sequence/types"

local motion = require "@self/motion/types"
local springs = require "@self/motion-springs/types"
local tweens = require "@self/motion-tweens/types"

local binds = require "@self/roblox-binds/types"
local instances = require "@self/roblox-instances/types"
local templates = require "@self/roblox-templates/types"

export type Scope<T = ConFusion> = memory.Scope<T>

export type GraphObject = graph.GraphObject

export type StateObject<T> = calc.StateObject<T>
export type Value<T> = calc.Value<T>
export type Computed<T> = calc.Computed<T>
export type Use = calc.Use
export type UsedAs<T> = calc.UsedAs<T>

export type Iter<K, V> = iter.Iter<K, V>
export type Range = iter_range.Range

export type Motion<T> = motion.Motion<T>
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
	read scoped: memory.DeriveScope,
	read deriveScope: memory.DeriveScope,
	read innerScope: memory.DeriveScope,
	read destroy: memory.Destroy,
	read insert: memory.Insert,

	-- Core: State
	read Computed: calc.ComputedConstructor,
	read Value: calc.ValueConstructor,

	-- Core: Graph
	read observe: graph.Observe,
	read observeImmediate: graph.Observe,

	-- Core: Use
	read peek: calc.Use,
	read flatten: use.Flatten,

	-- Iter: For
	read ForPairs: iter_for.ForPairsConstructor,
	read ForKeys: iter_for.ForKeysConstructor,
	read ForValues: iter_for.ForValuesConstructor,

	-- Iter: Range
	read ForRange: iter_range.ForRangeConstructor,
	read Range: iter_range.RangeConstructor,

	-- Async
	read Eventual: async.EventualConstructor,
	read await: async.Await,

	-- Context
	read Contextual: context.ContextConstructor,

	-- Chrono
	read Timer: chrono.TimerConstructor,

	-- Safe
	read Safe: safe.Safe,

	-- Sequence
	read Sequence: sequence.SequenceConstructor,

	-- Motion
	read Motion: motion.MotionConstructor,

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
	read OfName: templates.OfChildConstructor,
	read OfClass: templates.OfClassConstructor,
	read DescendantOfName: templates.OfChildConstructor,
	read DescendantOfClass: templates.OfClassConstructor,

	-- Roblox: Binds
	read PropertyOf: binds.PropertyOfConstructor,
	read AttributeOf: binds.AttributeOfConstructor,
}

local External = require "@self/core-external/External"

local RobloxProvider = require "@self/roblox-provider/RobloxProvider"
External.setProvider(RobloxProvider)

return table.freeze {
	version = table.freeze {
		major = 0,
		minor = 4,
	},

	-- Core: Memory
	scoped = require "@self/core-memory/scoped",
	deriveScope = require "@self/core-memory/deriveScope",
	innerScope = require "@self/core-memory/innerScope",
	destroy = require "@self/core-memory/destroy",
	insert = require "@self/core-memory/insert",

	-- Core: State
	Computed = require "@self/core-calc/Computed",
	Value = require "@self/core-calc/Value",

	-- Core: Graph
	observe = require "@self/core-graph/observe",
	observeImmediate = require "@self/core-graph/observeImmediate",

	-- Core: Use
	peek = require "@self/core-use/peek",
	flatten = require "@self/core-use/flatten",

	-- Iter: For
	ForPairs = require "@self/iter-for/ForPairs",
	ForKeys = require "@self/iter-for/ForKeys",
	ForValues = require "@self/iter-for/ForValues",

	-- Iter: Range
	ForRange = require "@self/iter-range/ForRange",
	Range = require "@self/iter-range/Range",

	-- Async
	Eventual = require "@self/async/Eventual",
	await = require "@self/async/await",

	-- Context
	Contextual = require "@self/context/Contextual",

	-- Chrono
	Timer = require "@self/chrono/Timer",

	-- Safe
	Safe = require "@self/safe/Safe",

	-- Sequence
	Sequence = require "@self/sequence/Sequence",

	-- Motion
	Motion = require "@self/motion/Motion",

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
} :: ConFusion
