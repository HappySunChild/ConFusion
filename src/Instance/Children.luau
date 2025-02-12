local package = script.Parent.Parent

local Kinds = require(package.Kinds)
local Symbols = require(package.Symbols)
local Types = require(package.Types)

local castToState = require(package.State.castToState)
local peek = require(package.State.peek)

type Child = Instance | { Child } | Types.UsedAs<Child>

local Children = {
	[Symbols.Kind] = Kinds.Key,
	[Symbols.Type] = Types.Children,

	apply = function(parent: Instance, children: { Child })
		local currentChildren = {}

		local function updateChildren()
			local removeChildren = currentChildren
			currentChildren = {}

			local function addChild(child: Child, name: string)
				local childType = typeof(child)

				if childType == 'table' then
					for key, subChild in child do
						addChild(subChild, key)
					end
				elseif childType == 'Instance' then
					currentChildren[child] = true
					removeChildren[child] = nil

					child.Parent = parent
					child.Name = name
				elseif castToState(child) then
					local value = peek(child)

					if value ~= nil then
						addChild(value)
					end

					child:onChange(updateChildren)
				else
					error(`Unknown child type, '{childType}'`, 2)
				end
			end

			addChild(children)

			for child in removeChildren do
				child.Parent = nil
			end

			table.clear(removeChildren)
		end

		updateChildren()
	end,
}

return Children
