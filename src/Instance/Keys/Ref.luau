local package = script.Parent.Parent.Parent

local Types = require(package.Types)

local typeof = require(package.Utility.typeOf)

local Ref: Types.SpecialKey = table.freeze {
	kind = 'key',
	type = 'ref',

	apply = function(_: Types.Scope, applyTo: Instance, ref: Types.Value<Instance>)
		if typeof(ref) ~= 'Value' then
			return error(`Invalid Ref type.`, 2)
		end

		ref:set(applyTo)

		return
	end,
}

return Ref
