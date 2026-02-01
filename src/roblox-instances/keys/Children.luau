local calc = require("../../core-calc/types")
local instances = require("../types")
local memory = require("../../core-memory/types")

local External = require("../../core-external/External")

local SpecialKey = require("./SpecialKey")
local cast_to_state = require("../../core-calc/cast_to_state")
local destroy = require("../../core-memory/destroy")
local observe_immediate = require("../../core-graph/observe_immediate")
local peek = require("../../core-use/peek")

type Set<T, V = true> = { [T]: V }

local function create_reconciler(
	scope: memory.Scope,
	processor: (
		child: instances.Child,
		parent: Instance?,
		new_children: Set<Instance>,
		new_scopes: Set<instances.Child, memory.Scope>,
		old_children: Set<Instance>,
		old_scopes: Set<instances.Child, memory.Scope>
	) -> ()
)
	local old_children: Set<Instance>, new_children: Set<Instance> = {}, {}
	local old_scopes: Set<instances.Child, memory.Scope>, new_scopes: Set<instances.Child, memory.Scope> =
		{}, {}

	local function reconcile(new_child: instances.Child?, parent: Instance?)
		old_children, new_children = new_children, old_children
		old_scopes, new_scopes = new_scopes, old_scopes

		if new_child ~= nil then
			processor(new_child, parent, new_children, new_scopes, old_children, old_scopes)
		end

		for old_child in old_children do
			old_child.Parent = nil
		end

		for _, scope in old_scopes do
			destroy(scope)
		end

		-- reparenting has been deferred to fix a bug with nested state objects
		for new_child in new_children do
			if new_child.Parent == nil then
				new_child.Parent = parent
			end
		end

		table.clear(old_children)
		table.clear(old_scopes)
	end

	-- cleanup
	table.insert(scope, function()
		reconcile(nil, nil)
	end)

	return reconcile
end

local function process_child(
	child: instances.Child,
	parent: Instance?,
	new_children: Set<Instance>,
	new_scopes: Set<instances.Child, memory.Scope>,
	old_children: Set<Instance>,
	old_scopes: Set<instances.Child, memory.Scope>
)
	local child_type = typeof(child)

	if child_type == "Instance" then
		child = child :: Instance

		new_children[child] = true
		old_children[child] = nil
	elseif child_type == "function" then
		child = child :: (Instance) -> instances.Child

		local actual_child = child(parent)

		if actual_child ~= nil then
			process_child(actual_child, parent, new_children, new_scopes, old_children, old_scopes)
		end
	elseif cast_to_state(child) ~= nil then
		child = child :: calc.StateNode<instances.Child>

		local child_scope = old_scopes[child]

		if child_scope == nil then
			child_scope = {}

			local reconcile = create_reconciler(child_scope, process_child)

			observe_immediate(child_scope, child, function()
				reconcile(peek(child), parent)
			end)
		else
			old_scopes[child] = nil
		end

		new_scopes[child] = child_scope
	elseif child_type == "table" then
		child = child :: { instances.Child }
		for _, descendant in child do
			process_child(descendant, parent, new_children, new_scopes, old_children, old_scopes)
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
	function(scope: memory.Scope, apply_to: Instance, root_child: instances.Child)
		local reconcile = create_reconciler(scope, process_child)
		reconcile(root_child, apply_to)
	end
)

return Children
