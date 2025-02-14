local package = script.Parent.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Observer = require(package.Graph.Observer)
local castToState = require(package.State.castToState)

local function setParent(instance: Instance, parent: Instance?)
	local success, err = pcall(function()
		instance.Parent = parent
	end)

	if not success then
		warn(err)
	end
end

local Parent = table.freeze {
	[Symbols.Type] = 'parent',
	[Symbols.Kind] = 'key',

	apply = function(scope: Types.Scope, instance: Instance, parent: Types.UsedAs<Instance?>)
		print('set parent', instance, parent)

		if castToState(parent) then
			Observer(scope, parent):onBind(function(new)
				setParent(instance, new)
			end)

			return
		end

		setParent(instance, parent)
	end,
}

return Parent
