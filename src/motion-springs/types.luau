local calc = require("../core-calc/types")
local memory = require("../core-memory/types")
local motion = require("../motion/types")

export type SpringConstructor = <T>(
	scope: memory.Scope,
	goal: calc.UsedAs<T>,
	speed: calc.UsedAs<number>?,
	damping: calc.UsedAs<number>?
) -> motion.Motion<T>

return nil
