local package = script.Parent.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local castToState = require(package.State.castToState)

local Ref: Types.SpecialKey = table.freeze {
	[Symbols.Kind] = 'key',
	[Symbols.Type] = 'ref',

	apply = function(_: Types.Scope, parent: Instance, ref: Types.Value<Instance>)
		if not castToState(ref) then
			return
		end

		ref:set(parent)
	end,
}

return Ref
