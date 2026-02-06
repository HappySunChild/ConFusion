local calc = require("../core-calc/types")
local graph = require("../core-graph/types")

export type Disassembly<OK, OV> = {
	populate: (Disassembly<OK, OV>, use: calc.Use, output: { [OK]: OV }) -> (),
} & graph.GraphNode

export type Iter<K, V> = {
	kind: "Iter",
	timeliness: "lazy",
} & calc.StateNode<{ [K]: V }>

return nil
