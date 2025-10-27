local calc = require "../core-calc/types"
local memory = require "../core-memory/types"

local properties = require "./properties"
local properties_fancy = require "./properties_fancy"

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

type New<Name, Class, Properties> = properties.New<Name, Class, Properties>

export type NewConstructor =
	& New<"Frame", Frame, properties.Frame>
	& New<"ScrollingFrame", ScrollingFrame, properties.ScrollingFrame>
	& New<"TextBox", TextBox, properties.TextBox>
	& New<"TextLabel", TextLabel, properties.TextLabel>
	& New<"TextButton", TextButton, properties.TextButton>
	& New<"ImageLabel", ImageLabel, properties.ImageLabel>
	& New<"ImageButton", ImageButton, properties.ImageButton>
	& New<"ViewportFrame", ViewportFrame, properties.ViewportFrame>
	& New<"CanvasGroup", CanvasGroup, properties.CanvasGroup>
	& New<
		"UIAspectRatioConstraint",
		UIAspectRatioConstraint,
		properties.UIAspectRatioConstraint
	>
	& New<"UISizeConstraint", UISizeConstraint, properties.UISizeConstraint>
	& New<"UITextSizeConstraint", UITextSizeConstraint, properties.UITextSizeConstraint>
	& New<"UICorner", UICorner, properties.UICorner>
	& New<"UIFlexItem", UIFlexItem, properties.UIFlexItem>
	& New<"UIGradient", UIGradient, properties.UIGradient>
	& New<"UIPadding", UIPadding, properties.UIPadding>
	& New<"UIScale", UIScale, properties.UIScale>
	& New<"UIStroke", UIStroke, properties.UIStroke>
	& New<"UIGridLayout", UIGridLayout, properties.UIGridLayout>
	& New<"UIListLayout", UIListLayout, properties.UIListLayout>
	& New<"UIPageLayout", UIPageLayout, properties.UIPageLayout>
	& New<"UITableLayout", UITableLayout, properties.UITableLayout>
	& New<string, Instance, properties._Instance>

-- export type NewConstructor =
-- & New<"CanvasGroup", CanvasGroup>
-- & New<"Frame", Frame>
-- & New<"ScrollingFrame", ScrollingFrame>
-- & New<"TextBox", TextBox>
-- & New<"TextLabel", TextLabel>
-- & New<"TextButton", TextButton>
-- & New<"ImageLabel", ImageLabel>
-- & New<"ImageButton", ImageButton>
-- & New<"VideoDisplay", VideoDisplay>
-- & New<"VideoFrame", VideoFrame>
-- & New<"ViewportFrame", ViewportFrame>
-- & New<"ScreenGui", ScreenGui>
-- & New<"SurfaceGui", SurfaceGui>
-- & New<"BillboardGui", BillboardGui>
-- & New<"AdGui", AdGui>
-- & New<"UIAspectRatioConstraint", UIAspectRatioConstraint>
-- & New<"UISizeConstraint", UISizeConstraint>
-- & New<"UITextSizeConstraint", UITextSizeConstraint>
-- & New<"UICorner", UICorner>
-- & New<"UIDragDetector", UIDragDetector>
-- & New<"UIFlexItem", UIFlexItem>
-- & New<"UIGradient", UIGradient>
-- & New<"UIGridLayout", UIGridLayout>
-- & New<"UIListLayout", UIListLayout>
-- & New<"UIPageLayout", UIPageLayout>
-- & New<"UITableLayout", UITableLayout>
-- & New<"UIPadding", UIPadding>
-- & New<"UIScale", UIScale>
-- & New<"UIStroke", UIStroke>
-- & New<string, Instance>

export type HydrateConstructor = <T>(
	scope: memory.Scope,
	instance: T & Instance
) -> (props: Properties) -> T

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
