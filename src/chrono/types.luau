local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type ExternalTime = calc.StateObject<number> & {
	kind: "ExternalTime",

	enable: (ExternalTime) -> (),
	disable: (ExternalTime) -> (),
	isEnabled: (ExternalTime) -> boolean,
}

export type Timer = calc.StateObject<number> & {
	kind: "Timer",

	pause: (Timer) -> (),
	unpause: (Timer) -> (),
	zero: (Timer) -> (),
}
export type TimerConstructor = (scope: memory.Scope) -> Timer

return nil
