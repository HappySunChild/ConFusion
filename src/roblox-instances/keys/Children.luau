local instances = require("../types")
local memory = require("../../core-memory/types")

local External = require("../../core-external/External")

local SpecialKey = require("./SpecialKey")
local cast_to_state = require("../../core-calc/cast_to_state")
local destroy = require("../../core-memory/destroy")
local observe_immediate = require("../../core-graph/observe_immediate")
local peek = require("../../core-use/peek")

local function process_child(
	child: instances.Child,
	parent: Instance,
	new_children: { [Instance]: true },
	old_children: { [Instance]: true },
	new_scopes: memory.Scope,
	old_scopes: memory.Scope
)
	local child_type = typeof(child)

	if child_type == "Instance" then
		child = child :: Instance

		if child.Parent == nil and old_children[child] == nil then
			child.Parent = parent
		end

		new_children[child] = true
		old_children[child] = nil
	elseif child_type == "function" then
		local child_instance = child(parent)

		if child_instance ~= nil then
			process_child(
				child_instance,
				parent,
				new_children,
				old_children,
				new_scopes,
				old_scopes
			)
		end
	elseif cast_to_state(child) ~= nil then
		local child_scope = old_scopes[child]

		if child_scope == nil then -- setup new scope and listen for changes
			child_scope = {}

			-- this could probably be moved into a separate function to cut down on duplicate code, but i feel like if i did that i'd break everything somehow

			local sub_new_children, sub_old_children = {}, {}
			local sub_new_scopes, sub_old_scopes = {}, {}

			table.insert(child_scope, function()
				for child in sub_new_children do
					child.Parent = nil
				end

				for _, scope in sub_new_scopes do
					destroy(scope)
				end
			end)

			observe_immediate(child_scope, child, function()
				sub_old_children, sub_new_children = sub_new_children, sub_old_children
				sub_old_scopes, sub_new_scopes = sub_new_scopes, sub_old_scopes

				local new_child = peek(child)

				if new_child ~= nil then
					process_child(
						new_child,
						parent,
						sub_new_children,
						sub_old_children,
						sub_new_scopes,
						sub_old_scopes
					)
				end

				for child in sub_old_children do
					child.Parent = nil
				end

				for _, scope in sub_old_scopes do
					destroy(scope)
				end

				table.clear(sub_old_children)
				table.clear(sub_old_scopes)
			end)
		else
			old_scopes[child] = nil
		end

		new_scopes[child] = child_scope
	elseif child_type == "table" then
		for _, descendant in child :: { instances.Child } do
			process_child(descendant, parent, new_children, old_children, new_scopes, old_scopes)
		end
	else
		External.log_error_nonfatal(
			instances.invalid_child_type,
			debug.traceback(nil, 2),
			child_type
		)
	end
end

local Children = SpecialKey(
	"descendants",
	"Children",
	function(scope: memory.Scope, parent: Instance, root_child: instances.Child?)
		local root_old_children: { [Instance]: true }, root_new_children: { [Instance]: true } =
			{}, {}
		local root_old_scopes: { memory.Scope }, root_new_scopes: { memory.Scope } = {}, {}

		table.insert(scope, function()
			for child in root_new_children do
				child.Parent = nil
			end

			for _, scope in root_new_scopes do
				destroy(scope)
			end
		end)

		process_child(
			root_child,
			parent,
			root_new_children,
			root_old_children,
			root_new_scopes,
			root_old_scopes
		)
	end
)

return Children
