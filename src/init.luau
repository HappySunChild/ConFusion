local Types = require(script.Types)

local State = script.State
local Animation = script.Animation
local Memory = script.Memory
local Utility = script.Utility

local Instance = script.Instance
local Keys = Instance.Keys

local ReFusion = table.freeze {
	scoped = require(Memory.scoped),
	deriveScope = require(Memory.deriveScope),
	innerScope = require(Memory.innerScope),
	doCleanup = require(Memory.doCleanup),

	Spring = require(Animation.Spring),
	Tween = require(Animation.Tween),
	Computed = require(State.Computed),
	ForPairs = require(State.ForPairs),
	Value = require(State.Value),
	Table = require(State.Table),
	peek = require(State.peek),

	New = require(Instance.New),
	Hydrate = require(Instance.Hydrate),

	Signal = require(Utility.Signal),
	Clock = require(Utility.Clock),

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
}

type ReFusion = typeof(ReFusion)
export type Scope<Constructors = ReFusion> = Types.Scope<Constructors>
export type UsedAs<V> = Types.UsedAs<V>

return ReFusion :: ReFusion
