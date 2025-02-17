local package = script.Parent.Parent.Parent

local External = require(package.External)
local Types = require(package.Types)

local castToState = require(package.State.castToState)
local doCleanup = require(package.Memory.doCleanup)
local observe = require(package.Graph.observe)
local peek = require(package.State.peek)

local Children: Types.SpecialKey = table.freeze {
	kind = 'key',
	type = 'children',

	apply = function(scope: Types.Scope, applyTo: Instance, children: Types.Child?)
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
						child.Parent = applyTo
					else
						oldChildren[child] = nil
					end

					if name then
						child.Name = name
					end
				--[[
				This is something I'm still considering.
				I thought about how you could technically have "unresolved children" by using a function that passes the parent and returns the child/children.
				Maybe this could be used during Hydrate to apply properties to existing children?
				(got the idea from this issue: https://github.com/dphfox/Fusion/issues/206)
				
				An example of what this could possibly look like in use:
				```
				local function ExistingChild(scope, childName)
					return function(props)
						-- this function gets called when updating the children.
						return function(parent)
							local child = parent:FindFirstChild(childName)
							
							applyProperties(scope, child, props)
							
							return child
						end
					end
				end
				```
				
				This function could then be used like this:
				```
				scope:Hydrate(screenGui) {
					[Children] = {
						-- this returns a function which sort of functions as a "unresolved" child.
						-- you could write variations of this function to work with `:WaitForChild`, `:FindFirstAncestor`, `:FindFirstChildOfClass`, etc.
						scope:ExistingChild "Label" {
							BackgroundColor3 = Color3.fromRGB(184, 85, 85),
							Text = "Hello world!"
							...etc
						}
					}
				}
				```
				
				I haven't thoroughly tested this, but just from this brief example I think it'd work pretty well.
				I could be wrong though!
				]]
				elseif childType == 'function' then
					local childInstance = child(applyTo)

					if childInstance then
						processChild(childInstance)
					end
				elseif castToState(child) then
					local value = peek(child)

					if value ~= nil then
						processChild(value, name)
					end

					local childScope = oldScopes[child]

					if not childScope then
						childScope = {}

						observe(child, updateChildren)
					else
						oldScopes[child] = nil
					end

					newScopes[child] = childScope
				elseif childType == 'table' then
					for key, subChild in child do
						processChild(subChild, key)
					end
				else
					External.logErrorNonFatal(
						'invalidChildType',
						debug.traceback(nil, 2),
						childType
					)
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
