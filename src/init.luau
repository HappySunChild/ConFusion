local Types = require(script.Types)

local ReFusion = table.freeze {
	scoped = require(script.Memory.scoped),
	deriveScope = require(script.Memory.deriveScope),
	doCleanup = require(script.Memory.doCleanup),

	Tween = require(script.Animation.Tween),
	Computed = require(script.State.Computed),
	ForPairs = require(script.State.ForPairs),
	Value = require(script.State.Value),
	Table = require(script.State.Table),
	peek = require(script.State.peek),

	Observer = require(script.Graph.Observer),

	New = require(script.Instance.New),
	Hydrate = require(script.Instance.Hydrate),

	Signal = require(script.Utility.Signal),
	Clock = require(script.Utility.Clock),

	Children = require(script.Instance.Children),
	Startup = require(script.Instance.Startup),
	Cleanup = require(script.Instance.Cleanup),
	Ref = require(script.Instance.Ref),
	Out = require(script.Instance.Out),
	OnEvent = require(script.Instance.OnEvent),
}

type ReFusion = typeof(ReFusion)
export type Scope<Constructors = ReFusion> = Types.Scope<Constructors>
export type UsedAs<V> = Types.UsedAs<V>

return ReFusion :: ReFusion
