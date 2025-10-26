local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

export type SpecialKeyStage =
	"self"
	| "descendants"
	| "properties"
	| "ancestor"
	| "observer"
	| "last"

export type SpecialKey<T = string> = {
	type: T,
	kind: "key",
	stage: SpecialKeyStage,

	apply: (scope: memory.Scope, instance: Instance, value: any) -> (),
}

export type Properties = {
	[SpecialKey]: any,
}

export type Child =
	Instance
	| ((Instance) -> Instance?)
	| { Child }
	| calc.StateObject<Child>

type function PropertiesOf(class: type)
	local BLACKLISTED_PROPERTIES = {
		"RobloxLocked",
		"GuiState",
		"AbsolutePosition",
		"AbsoluteRotation",
		"AbsoluteSize",
	}

	local output = {}

	local current = class

	-- max depth
	for _ = 1, 5 do
		if current == nil then
			break
		end

		for key, value in current:properties() do
			local v_write = value.write

			if
				v_write == nil
				or v_write:is "function"
				or v_write:is "table"
				or v_write:is "intersection"
			then
				continue
			end

			if table.find(BLACKLISTED_PROPERTIES, key:value()) then
				continue
			end

			output[key] = types.any
		end

		current = current:readparent()
	end

	return types.newtable(output)
end

type Hydrate<Class> = (
	scope: memory.Scope,
	instance: Class
) -> (props: Properties) -> Class
type New<Name, Class> = (
	scope: memory.Scope,
	class_name: Name
) -> (props: PropertiesOf<Class>) -> Class

export type NewConstructor =
	& New<"CanvasGroup", CanvasGroup>
	& New<"Frame", Frame>
	& New<"ScrollingFrame", ScrollingFrame>
	& New<"TextBox", TextBox>
	& New<"TextLabel", TextLabel>
	& New<"TextButton", TextButton>
	& New<"ImageLabel", ImageLabel>
	& New<"ImageButton", ImageButton>
	-- & New<"VideoDisplay", VideoDisplay>
	-- & New<"VideoFrame", VideoFrame>
	& New<"ViewportFrame", ViewportFrame>
	& New<"ScreenGui", ScreenGui>
	& New<"SurfaceGui", SurfaceGui>
	& New<"BillboardGui", BillboardGui>
	-- & New<"AdGui", AdGui>
	& New<"UIAspectRatioConstraint", UIAspectRatioConstraint>
	& New<"UISizeConstraint", UISizeConstraint>
	& New<"UITextSizeConstraint", UITextSizeConstraint>
	& New<"UICorner", UICorner>
	-- & New<"UIDragDetector", UIDragDetector>
	& New<"UIFlexItem", UIFlexItem>
	& New<"UIGradient", UIGradient>
	& New<"UIGridLayout", UIGridLayout>
	& New<"UIListLayout", UIListLayout>
	& New<"UIPageLayout", UIPageLayout>
	& New<"UITableLayout", UITableLayout>
	& New<"UIPadding", UIPadding>
	& New<"UIScale", UIScale>
	& New<"UIStroke", UIStroke>
	& New<string, Instance>
export type HydrateConstructor = & Hydrate<Instance>

return {
	cannotCreateClass = "Unable to create instance of type '%s'.",
	cannotConnectChange = "The %s class doesn't have a property called '%s'.",
	cannotConnectEvent = "The %s class doesn't have a event called '%s'.",

	propertyInvalidType = "'%s.%s' expected a '%s' type, but got a '%s' type.",
	propertyCannotAssign = "The %s class has no assignable property '%s'.",
	propertyAssignError = "Error while setting property:\nERROR_MESSAGE",

	invalidChildType = "Invalid child type '%s'.",

	missingSpecialKeyStage = "The SpecialKey '%s' is missing a stage property.",
	invalidSpecialKeyStage = "The SpecialKey '%s' has an invalid stage '%s'.",

	expectedType = "Expected a %s, got %s.",
}
