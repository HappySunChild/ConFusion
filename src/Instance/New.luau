local package = script.Parent.Parent

local Types = require(package.Types)

local applyProperties = require(package.Instance.applyProperties)
local defaultProperties = require(package.Instance.defaultProperties)

local function New(scope: Types.Scope, classNameOrTemplate: string | Instance)
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

	return function(props: Types.Properties)
		table.insert(scope, instance)

		applyProperties(scope, instance, props)

		return instance
	end
end

return New
