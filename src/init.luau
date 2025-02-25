--!strict
local External = require(script.External)
local Types = require(script.Types)

local Animation = script.Animation
local Graph = script.Graph
local State = script.State
local Memory = script.Memory
local Utility = script.Utility

local Instance = script.Instance
local Keys = Instance.Keys

local ReFusion = table.freeze {
	scoped = require(Memory.scoped),
	deriveScope = require(Memory.deriveScope),
	innerScope = require(Memory.innerScope),
	doCleanup = require(Memory.doCleanup),

	Computed = require(State.Computed),
	Value = require(State.Value),
	Table = require(State.Table),
	ForPairs = require(State.ForPairs),
	ForKeys = require(State.ForKeys),
	ForValues = require(State.ForValues),
	peek = require(State.peek),
	observe = require(Graph.observe),

	-- Animation
	Timer = require(Animation.Timer),
	Animated = require(Animation.Animated),
	Tween = require(Animation.Tween),
	Spring = require(Animation.Spring),
	Delay = require(Animation.Delay),

	-- Instance
	New = require(Instance.New),
	Child = require(Instance.Child),
	ChildOfClass = require(Instance.ChildOfClass),
	Descendant = require(Instance.Descendant),
	DescendantOfClass = require(Instance.DescendantOfClass),

	-- Instance Keys
	Children = require(Keys.Children),
	Startup = require(Keys.Startup),
	Cleanup = require(Keys.Cleanup),
	Ref = require(Keys.Ref),
	Apply = require(Keys.Apply),
	Attribute = require(Keys.Attribute),
	AttributeChange = require(Keys.AttributeChange),
	AttributeOut = require(Keys.AttributeOut),
	Tag = require(Keys.Tag),
	Out = require(Keys.Out),
	OnEvent = require(Keys.OnEvent),
	OnChange = require(Keys.OnChange),

	-- Utility
	Signal = require(Utility.Signal),
}

if game then
	local RobloxProvider = require(script.RobloxProvider)
	External.setProvider(RobloxProvider)
end

type ReFusion = typeof(ReFusion)
export type Scope<Constructors = ReFusion> = Types.Scope<Constructors>
export type UsedAs<V> = Types.UsedAs<V>

return ReFusion :: ReFusion
