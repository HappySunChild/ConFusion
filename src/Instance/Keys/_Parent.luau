local package = script.Parent.Parent.Parent

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
	type = 'parent',
	kind = 'key',

	apply = function(
		scope: Types.Scope,
		applyTo: Instance,
		parent: Types.UsedAs<Instance?>
	)
		if castToState(parent) then
			Observer(scope, parent):onBind(function(new)
				setParent(applyTo, new)
			end)

			return
		end

		setParent(applyTo, parent)
	end,
}

return Parent
