local package = script.Parent.Parent

local Types = require(package.Types)

local Children = require(package.Instance.Keys.Children)
local applyProperties = require(package.Instance.applyProperties)
local defaultProperties = require(package.Instance.defaultProperties)

local function New(
	scope: Types.Scope,
	classNameOrTemplate: string | Instance,
	props: Types.Properties,
	children: Types.Child
)
	local instance

	if typeof(classNameOrTemplate) == 'Instance' then
		instance = classNameOrTemplate:Clone()
	else
		local success, newInstance = pcall(Instance.new, classNameOrTemplate)

		if not success then
			error(`Unable to create instance of type '{typeof(classNameOrTemplate)}'`, 2)

			return
		end

		local classProps = defaultProperties[classNameOrTemplate]

		if classProps then
			for key, value in classProps do
				newInstance[key] = value
			end
		end

		instance = newInstance
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
