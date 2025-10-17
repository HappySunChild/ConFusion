local calc = require "../calc/types"
local memory = require "../memory/types"
local motion = require "../motion/types"

export type SpringConstructor = <V>(
	scope: memory.Scope,
	goal: calc.UsedAs<V>,
	speed: calc.UsedAs<number>?,
	damping: calc.UsedAs<number>?
) -> motion.Animated<V>

return nil
