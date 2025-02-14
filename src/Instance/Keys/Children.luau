local package = script.Parent.Parent.Parent

local Symbols = require(package.Symbols)
local Types = require(package.Types)

local Observer = require(package.Graph.Observer)

local castToState = require(package.State.castToState)
local doCleanup = require(package.Memory.doCleanup)
local peek = require(package.State.peek)

local Children: Types.SpecialKey = table.freeze {
	[Symbols.Kind] = 'key',
	[Symbols.Type] = 'children',

	apply = function(scope: Types.Scope, parent: Instance, children: Types.Child)
		local newChildren, oldChildren = {}, {}
		local newScopes, oldScopes = {}, {}

		local function updateChildren()
			oldChildren, newChildren = newChildren, oldChildren
			oldScopes, newScopes = newScopes, oldScopes

			local function processChild(child: Types.Child, name: string?)
				local childType = typeof(child)

				if childType == 'Instance' then
					newChildren[child] = true

					if not oldChildren[child] then
						child.Parent = parent
					else
						oldChildren[child] = nil
					end

					if name then
						child.Name = name
					end
				elseif castToState(child) then
					local value = peek(child)

					if value ~= nil then
						processChild(value, name)
					end

					local childScope = oldScopes[child]

					if not childScope then
						childScope = {}
						Observer(childScope, child):onChange(updateChildren)
					else
						oldScopes[child] = nil
					end

					newScopes[child] = childScope
				elseif childType == 'table' then
					for key, subChild in child do
						processChild(subChild, key)
					end
				else
					error(`Unknown child type, '{childType}'`, 2)
				end
			end

			if children then
				processChild(children)
			end

			for instance in oldChildren do
				instance.Parent = nil
			end

			table.clear(oldChildren)

			for _, childScope in oldScopes do
				doCleanup(childScope)
			end

			table.clear(oldScopes)
		end

		table.insert(scope, function()
			children = nil
			updateChildren()
		end)

		updateChildren()
	end,
}

return Children
