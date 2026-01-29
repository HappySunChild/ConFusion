local calc = require "./core-calc/types"
local external = require "./core-external/types"
local graph = require "./core-graph/types"
local memory = require "./core-memory/types"
local use = require "./core-use/types"

local External = require "./core-external/External"
local ExternalDebugger = require "./core-external/ExternalDebug"

local merge = require "./core-memory/merge"

type Version = {
	read major: number,
	read minor: number,
}

type Configuration<I> = {
	version: Version,
	provider: external.ExternalProvider,
	debugger: external.ExternalDebugger?,
	include: I,
}

export type ConFusion<I = any> = {
	version: Version,

	-- Core: Memory
	scoped: memory.DeriveScope,
	derive_scope: memory.DeriveScope,
	inner_scope: memory.DeriveScope,
	destroy: memory.Destroy,
	insert: memory.Insert,

	-- Core: State
	Computed: calc.ComputedConstructor,
	Value: calc.ValueConstructor,

	-- Core: Graph
	observe: graph.Observe,
	observe_immediate: graph.Observe,

	-- Core: Use
	peek: calc.Use,
	flatten: use.Flatten,
} & I

local CORE_CONFUSION = table.freeze {
	derive_scope = require "./core-memory/derive_scope",
	destroy = require "./core-memory/destroy",
	inner_scope = require "./core-memory/inner_scope",
	insert = require "./core-memory/insert",
	scoped = require "./core-memory/scoped",

	Computed = require "./core-calc/Computed",
	Value = require "./core-calc/Value",

	observe = require "./core-graph/observe",
	observe_immediate = require "./core-graph/observe_immediate",

	flattern = require "./core-use/flatten",
	peek = require "./core-use/peek",
}

local ConFusion = table.freeze {
	configure = function<I>(options: Configuration<I>): ConFusion<I>
		External.set_provider(options.provider)
		ExternalDebugger.set_debugger(options.debugger)

		local include = options.include

		assert(type(include) == "table", "`include` field should be a table!")

		local new_confusion = merge(
			true,
			table.clone(CORE_CONFUSION),
			include,
			{ version = options.version } -- always override version field
		)

		return new_confusion :: ConFusion<I>
	end,
}

return ConFusion
