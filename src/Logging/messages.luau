return {
	infiniteLoop = "Detected an infinite loop. Consider adding an explicit breakpoint to your code to prevent a cyclic dependency.",
	callbackError = "Error in callback:\nERROR_MESSAGE",
	missingChild = "Could not find child '%s' in '%s'.",

	invalidChildType = "Invalid child type '%s'.",
	invalidObserveType = "Can't observe non-state value, got '%s'.",

	propertyInvalidType = "'%s.%s' expected a '%s' type, but got a '%s' type.",
	propertyCannotAssign = "The %s class has no assignable property '%s'.",
	propertyAssignError = "Error while setting property:\nERROR_MESSAGE",

	cannotDepend = "%s cannot depend on %s.",
	cannotCreateClass = "Unable to create instance of type '%s'.",
	cannotCreateTemplate = "Unable to create template of instance '%s'.",
	cannotConnectChange = "The %s class doesn't have a property called '%s'.",
	cannotConnectEvent = "The %s class doesn't have a event called '%s'.",
}
