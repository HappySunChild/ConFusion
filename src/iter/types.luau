local calc = require "../core-calc/types"
local graph = require "../core-graph/types"

export type Disassembly<OK, OV> = {
	populate: (Disassembly<OK, OV>, use: calc.Use, output: { [OK]: OV }) -> (),
} & graph.GraphObject

export type Iter<K, V> = {
	type: "Iter",
	timeliness: "lazy",
} & calc.StateObject<{ [K]: V }>

return nil
