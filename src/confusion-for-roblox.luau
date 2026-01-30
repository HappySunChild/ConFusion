--[[
package: confusion-for-roblox

ConFusion - A variant of Fusion that will cause confusion.

GitHub Repository: https://github.com/HappySunChild/ConFusion
Fusion on GitHub: https://github.com/dphfox/Fusion
--]]

local calc = require("./core-calc/types")
local graph = require("./core-graph/types")
local memory = require("./core-memory/types")

local async = require("./async/types")
local chrono = require("./chrono/types")
local context = require("./context/types")
local keyframes = require("./keyframes/types")
local pipeline = require("./pipeline/types")
local safe = require("./safe/types")

local iter = require("./iter/types")
local iter_for = require("./iter-for/types")
local iter_range = require("./iter-range/types")

local motion = require("./motion/types")
local springs = require("./motion-springs/types")
local tweens = require("./motion-tweens/types")

local binds = require("./roblox-binds/types")
local instances = require("./roblox-instances/types")
local templates = require("./roblox-templates/types")

local confusion = require("./confusion")

export type Scope<T = ConFusionForRoblox> = memory.Scope<T>

export type GraphNode = graph.GraphNode
export type StateNode<T> = calc.StateNode<T>
export type UsedAs<T> = calc.UsedAs<T>

export type Value<T> = calc.Value<T>
export type Computed<T> = calc.Computed<T>
export type Use = calc.Use

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

type ConFusionForRoblox = confusion.ConFusion<{
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

	-- Keyframes
	read Keyframes: keyframes.KeyframesConstructor,

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
	read Attributes: instances.SpecialKey<"Attributes">,
	read AttributeChange: (attribute: string) -> instances.SpecialKey<"AttributeChange">,
	read AttributeOut: (attribute: string) -> instances.SpecialKey<"AttributeOut">,
	read Tag: (tag: string) -> instances.SpecialKey<"Tag">,
	read Tags: instances.SpecialKey<"Tags">,
	read Out: (property: string) -> instances.SpecialKey<"Out">,
	read OnEvent: (event: string) -> instances.SpecialKey<"OnEvent">,
	read OnChange: (property: string) -> instances.SpecialKey<"OnChange">,

	-- Roblox: Templates
	read FromTemplate: templates.FromTemplateConstructor,
	read QueryDescendants: templates.QueryDescendants,

	-- Roblox: Binds
	read PropertyOf: binds.PropertyOfConstructor,
	read AttributeOf: binds.AttributeOfConstructor,
}>

local confusion_for_roblox = confusion.configure({
	version = { major = 1, minor = 0 },
	provider = require("./roblox-provider/RobloxProvider"),
	debugger = nil,
	include = {
		-- Iter: For
		ForPairs = require("./iter-for/ForPairs"),
		ForKeys = require("./iter-for/ForKeys"),
		ForValues = require("./iter-for/ForValues"),

		-- Iter: Range
		ForRange = require("./iter-range/ForRange"),
		Range = require("./iter-range/Range"),

		-- Async
		Eventual = require("./async/Eventual"),
		await = require("./async/await"),

		-- Context
		Contextual = require("./context/Contextual"),

		-- Chrono
		Timer = require("./chrono/Timer"),

		-- Safe
		Safe = require("./safe/Safe"),

		-- Keyframes
		Keyframes = require("./keyframes/Keyframes"),

		-- Motion
		Motion = require("./motion/Motion"),

		-- Motion: Springs
		Spring = require("./motion-springs/Spring"),

		-- Motion: Tweens
		Tween = require("./motion-tweens/Tween"),
		TweenInfo = require("./motion-tweens/TweenInfo"),
		EasingStyles = require("./motion-tweens/EasingStyles"),

		-- Pipeline
		Pipe = require("./pipeline/Pipe"),

		-- Roblox: Instances
		New = require("./roblox-instances/New"),
		Hydrate = require("./roblox-instances/Hydrate"),

		Children = require("./roblox-instances/keys/Children"),
		OnStartup = require("./roblox-instances/keys/OnStartup"),
		OnRemoval = require("./roblox-instances/keys/OnRemoval"),
		Passthrough = require("./roblox-instances/keys/Passthrough"),
		Ref = require("./roblox-instances/keys/Ref"),
		Attribute = require("./roblox-instances/keys/Attribute"),
		Attributes = require("./roblox-instances/keys/Attributes"),
		AttributeChange = require("./roblox-instances/keys/AttributeChange"),
		AttributeOut = require("./roblox-instances/keys/AttributeOut"),
		Tag = require("./roblox-instances/keys/Tag"),
		Tags = require("./roblox-instances/keys/Tags"),
		Out = require("./roblox-instances/keys/Out"),
		OnEvent = require("./roblox-instances/keys/OnEvent"),
		OnChange = require("./roblox-instances/keys/OnChange"),

		-- Roblox: Templates
		FromTemplate = require("./roblox-templates/FromTemplate"),
		QueryDescendants = require("./roblox-templates/QueryDescendants"),

		-- Roblox: Binds
		PropertyOf = require("./roblox-binds/PropertyOf"),
		AttributeOf = require("./roblox-binds/AttributeOf"),
	},
})

return confusion_for_roblox :: ConFusionForRoblox
