-- all writable properties for some Instance classes.
-- this is different from PropertiesOf, in that it probably won't blow up your computer as much

-- ok so actually this is like just as laggy, if not more, than the PropertiesOf approach lol
-- i guess it's nicer than the PropertiesOf though, because we get to manually specify what properties are allowed
-- thats also the downside though, have to manually update properties when they're added/remove/deprecated

-- it seems that !strict typechecking is just a no go with property autocompletion, unless roblox makes
-- it so we don't need to overload a function 3000 times to get a resemblance of it.

local memory = require "../core-memory/types"

export type _Instance = {
	Archivable: boolean,
	Parent: Instance,
}

type _GuiBase2d = _Instance & {
	AutoLocalize: boolean,
	RootLocalizationTable: LocalizationTable,
	SelectionBehaviorDown: Enum.SelectionBehavior,
	SelectionBehaviorLeft: Enum.SelectionBehavior,
	SelectionBehaviorRight: Enum.SelectionBehavior,
	SelectionBehaviorUp: Enum.SelectionBehavior,
	SelectionGroup: boolean,
}
type _GuiObject = _GuiBase2d & {
	Active: boolean,
	AnchorPoint: Vector2,
	AutomaticSize: Enum.AutomaticSize,
	BackgroundColor3: Color3,
	BackgroundTransparency: number,
	BorderColor3: Color3,
	BorderMode: Enum.BorderMode,
	BorderSizePixel: number,
	ClipsDescendants: boolean,
	Interactable: boolean,
	LayoutOrder: number,
	NextSelectionDown: GuiObject,
	NextSelectionLeft: GuiObject,
	NextSelectionRight: GuiObject,
	NextSelectionUp: GuiObject,
	Position: UDim2,
	Rotation: number,
	Selectable: boolean,
	SelectionImageObject: GuiObject,
	SelectionOrder: number,
	Size: UDim2,
	SizeConstraint: Enum.SizeConstraint,
	Visible: boolean,
	ZIndex: number,
}

type _GuiButton = _GuiObject & {
	AutoButtonColor: boolean,
	HoverHapticEffect: HapticEffect,
	Modal: boolean,
	PressHapticeffect: HapticEffect,
	Selected: boolean,
	Style: Enum.ButtonStyle,
}

type _GuiImageBase = {
	Image: string,
	ImageColor3: Color3,
	ImageContent: Content,
	ImageRectOffset: Vector2,
	ImageRectSize: Vector2,
	ImageTransparency: number,
	ResampleMode: Enum.ResamplerMode,
	ScaleType: Enum.ScaleType,
	SliceCenter: Rect,
	SliceScale: number,
	TileSize: UDim,
}
type _GuiTextBase = {
	Font: Enum.Font,
	FontFace: Font,
	LineHeight: number,
	MaxVisibleGraphemes: number,
	RichText: boolean,
	Text: string,
	TextColor3: Color3,
	TextDirection: Enum.TextDirection,
	TextScaled: boolean,
	TextSize: number,
	TextStrokeColor3: Color3,
	TextStrokeTransparency: number,
	TextTransparency: number,
	TextTruncate: Enum.TextTruncate,
	TextWrapped: boolean,
	TextXAlignment: Enum.TextXAlignment,
	TextYAlignment: Enum.TextYAlignment,
}

type _UIGridStyleLayout = _Instance & {
	FillDirection: Enum.FillDirection,
	SortOrder: Enum.SortOrder,
	HorizontalAlignment: Enum.HorizontalAlignment,
	VericalAlignment: Enum.VerticalAlignment,
}

export type ImageButton = _GuiImageBase & _GuiButton & {
	HoverImage: string,
	HoverImageContent: Content,
	PressedImage: string,
	PressedImageContent: Content,
}
export type ImageLabel = _GuiImageBase & _GuiObject

export type TextButton = _GuiTextBase & _GuiButton
export type TextLabel = _GuiTextBase & _GuiObject
export type TextBox = _GuiTextBase & _GuiObject & {
	ClearTextOnFocus: boolean,
	CursorPosition: number,
	MultiLine: boolean,
	PlaceholderColor3: Color3,
	PlaceholderText: string,
	SelectionStart: number,
	ShowNativeInput: boolean,
}

export type Frame = _GuiObject & {
	Style: Enum.FrameStyle,
}
export type CanvasGroup = _GuiObject & {
	GroupColor3: Color3,
	GroupTransparency: number,
}
export type ScrollingFrame = _GuiObject & {
	AutomaticCanvasSize: Enum.AutomaticSize,
	BottomImage: string,
	BottomImageContent: Content,
	CanvasPosition: Vector2,
	CanvasSize: UDim2,
	ElasticBehavior: Enum.ElasticBehavior,
	HorizontalScrollBarInset: Enum.ScrollBarInset,
	MidImage: string,
	MidImageContent: Content,
	ScrollBarImageColor3: Color3,
	ScrollBarImageTransparency: number,
	ScrollBarThickness: number,
	ScrollingDirection: Enum.ScrollingDirection,
	ScrollingEnabled: boolean,
	TopImage: string,
	TopImageContent: Content,
	VerticalBarInset: Enum.ScrollBarInset,
	VerticalScrollBarPosition: Enum.VerticalScrollBarPosition,
}
export type ViewportFrame = _GuiObject & {
	Ambient: Color3,
	CurrentCamera: Camera,
	ImageColor3: Color3,
	ImageTransparency: number,
	LightColor3: Color3,
	LightDirection: Vector3,
}

export type UIAspectRatioConstraint = _Instance & {
	AspectRatio: number,
	AspectType: Enum.AspectType,
	DominantAxis: Enum.DominantAxis,
}
export type UISizeConstraint = _Instance & {
	MaxSize: Vector2,
	MinSize: Vector2,
}
export type UITextSizeConstraint = _Instance & {
	MaxTextSize: number,
	MinTextSize: number,
}
export type UICorner = _Instance & {
	CornerRadius: UDim,
}
export type UIFlexItem = _Instance & {
	FlexMode: Enum.UIFlexMode,
	ItemLineAlignment: Enum.ItemLineAlignment,
	GrowRatio: number,
	ShrinkRatio: number,
}
export type UIGradient = _Instance & {
	Color: ColorSequence,
	Enabled: boolean,
	Offset: Vector2,
	Rotation: number,
	Transparency: NumberSequence,
}
export type UIPadding = _Instance & {
	PaddingBottom: UDim,
	PaddingLeft: UDim,
	PaddingTop: UDim,
	PaddingRight: UDim,
}
export type UIScale = _Instance & {
	Scale: number,
}
export type UIStroke = _Instance & {
	ApplyStrokeMode: Enum.ApplyStrokeMode,
	BorderOffset: UDim,
	BorderStrokePosition: Enum.BorderStrokePosition,
	Color: Color3,
	Enabled: boolean,
	LineJoinMode: Enum.LineJoinMode,
	StrokeSizingMode: Enum.StrokeSizingMode,
	Thickness: number,
	Transparency: number,
	ZIndex: number,
}

export type UIGridLayout = _UIGridStyleLayout & {
	CellPadding: UDim2,
	CellSize: UDim2,
	FillDirectionMaxCells: number,
	StartCorner: Enum.StartCorner,
}
export type UIListLayout = _UIGridStyleLayout & {
	HorizontalFlex: Enum.UIFlexAlignment,
	VericalFlex: Enum.UIFlexAlignment,
	ItemLineAlignment: Enum.ItemLineAlignment,
	Padding: UDim,
	Wraps: boolean,
}
export type UIPageLayout = _UIGridStyleLayout & {
	Animated: boolean,
	Circular: boolean,
	CurrentPage: GuiObject,
	EasingDirection: Enum.EasingDirection,
	EasingStyle: Enum.EasingStyle,
	GamepadInputEnabled: boolean,
	Padding: UDim,
	ScrollWheelInputEnabled: boolean,
	TouchInputEnabled: boolean,
	TweenTime: number,
}
export type UITableLayout = _UIGridStyleLayout & {
	FillEmptySpaceColumns: boolean,
	FillEmptySpaceRows: boolean,
	MajorAxis: Enum.TableMajorAxis,
	Padding: UDim2,
}

export type New<Name, Class, Properties> = (
	scope: memory.Scope,
	class_name: Name
) -> (props: Properties) -> Class

return nil
