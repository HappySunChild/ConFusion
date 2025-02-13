local package = script.Parent.Parent

local Types = require(package.Types)

local Children = require(script.Parent.Children)
local applyProperties = require(script.Parent.applyProperties)
local defaultProperties = require(script.Parent.defaultProperties)

local function New(scope: Types.Scope, className: string, props: Types.Properties, children: Types.Child)
	local success, instance = pcall(Instance.new, className)

	if not success then
		error(`Unable to create instance of type '{typeof(className)}'`, 2)

		return
	end

	local classProps = defaultProperties[className]

	if classProps then
		for key, value in classProps do
			instance[key] = value
		end
	end

	props = props or {}

	if children then
		props[Children] = children
	end

	table.insert(scope, instance)
	applyProperties(scope, instance, props)

	return instance
end

return New
