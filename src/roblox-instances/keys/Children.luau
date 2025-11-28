local instances = require "../types"
local memory = require "../../core-memory/types"

local External = require "../../core-external/External"

local cast_to_state = require "../../core-calc/cast_to_state"

local peek = require "../../core-use/peek"

local destroy = require "../../core-memory/destroy"

local observe = require "../../core-graph/observe"

local SpecialKey = require "./SpecialKey"

local Children = SpecialKey(
	"descendants",
	"Children",
	function(scope: memory.Scope, apply_to: Instance, children: instances.Child?)
		local new_children, old_children = {}, {}
		local new_scopes, old_scopes = {}, {}

		local function updateChildren()
			old_children, new_children = new_children, old_children
			old_scopes, new_scopes = new_scopes, old_scopes

			local function processChild(child: instances.Child, name: string?)
				local child_type = typeof(child)

				if child_type == "Instance" then
					new_children[child] = true

					if old_children[child] == nil then
						if child.Parent == nil then
							child.Parent = apply_to
						end
					else
						old_children[child] = nil
					end

					if name ~= nil and tonumber(name) == nil then
						child.Name = name
					end
				elseif child_type == "function" then
					local child_instance = child(apply_to, name)

					if child_instance then
						processChild(child_instance, name)
					end
				elseif cast_to_state(child) ~= nil then
					local value = peek(child)

					if value ~= nil then
						processChild(value, name)
					end

					local child_scope = old_scopes[child]

					if child_scope == nil then
						child_scope = {}
						observe(child_scope, child, updateChildren)
					else
						old_scopes[child] = nil
					end

					new_scopes[child] = child_scope
				elseif child_type == "table" then
					for key, descendant in child do
						processChild(descendant, key)
					end
				else
					External.log_error_non_fatal(
						instances.invalid_child_type,
						debug.traceback(nil, 2),
						child_type
					)
				end
			end

			if children ~= nil then
				processChild(children)
			end

			for instance in old_children do
				instance.Parent = nil
			end

			table.clear(old_children)

			for _, child_scope in old_scopes do
				destroy(child_scope)
			end

			table.clear(old_scopes)
		end

		table.insert(scope, function()
			children = nil

			updateChildren()
		end)

		updateChildren()
	end
)

return Children
