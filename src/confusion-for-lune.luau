--[[
package: confusion-for-lune

ConFusion - A variant of Fusion that will cause confusion.

GitHub Repository: https://github.com/HappySunChild/ConFusion
Fusion on GitHub: https://github.com/dphfox/Fusion
--]]

local calc = require("./core-calc/types")
local graph = require("./core-graph/types")
local memory = require("./core-memory/types")

local confusion = require("./confusion")

export type Scope<T = ConFusionForLune> = memory.Scope<T>

export type GraphNode = graph.GraphNode
export type StateNode<T> = calc.StateNode<T>
export type UsedAs<T> = calc.UsedAs<T>

export type Value<T> = calc.Value<T>
export type Computed<T> = calc.Computed<T>
export type Use = calc.Use

type ConFusionForLune = confusion.ConFusion<{}>

local confusion_for_lune = confusion.configure({
	version = { major = 1, minor = 0 },
	provider = require("./lune-provider/LuneProvider"),
	debugger = nil,
	include = {},
})

return confusion_for_lune
