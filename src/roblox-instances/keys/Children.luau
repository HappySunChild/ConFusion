local instances = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"

local observe = require "../../core-graph/observe"

local castToState = require "../../core-calc/castToState"

local peek = require "../../core-use/peek"

local doCleanup = require "../../core-memory/doCleanup"

local SpecialKey = require "./SpecialKey"

local Children = SpecialKey "descendants" {
	name = "Children",
	apply = function(scope: memory.Scope, apply_to: Instance, children: instances.Child?)
		local new_children, old_children = {}, {}
		local new_scopes, old_scopes = {}, {}

		local function updateChildren()
			old_children, new_children = new_children, old_children
			old_scopes, new_scopes = new_scopes, old_scopes

			local function processChild(child: instances.Child, name: string?)
				local childType = typeof(child)

				if childType == "Instance" then
					new_children[child] = true

					if not old_children[child] then
						if child.Parent == nil then
							child.Parent = apply_to
						end
					else
						old_children[child] = nil
					end

					if name and tonumber(name) == nil then
						child.Name = name
					end
				elseif childType == "function" then
					local childInstance = child(apply_to, name)

					if childInstance then
						processChild(childInstance, name)
					end
				elseif castToState(child) then
					local value = peek(child)

					if value ~= nil then
						processChild(value, name)
					end

					local childScope = old_scopes[child]

					if childScope == nil then
						childScope = {}
						observe(childScope, child, updateChildren)
					else
						old_scopes[child] = nil
					end

					new_scopes[child] = childScope
				elseif childType == "table" then
					for key, subChild in child do
						processChild(subChild, key)
					end
				else
					External.logErrorNonFatal(
						instances.invalidChildType,
						debug.traceback(nil, 2),
						childType
					)
				end
			end

			if children then
				processChild(children)
			end

			for instance in old_children do
				instance.Parent = nil
			end

			table.clear(old_children)

			for _, childScope in old_scopes do
				doCleanup(childScope)
			end

			table.clear(old_scopes)
		end

		table.insert(scope, function()
			children = nil

			updateChildren()
		end)

		updateChildren()
	end,
}

return Children
