# ConFusion Styleguide

The way code in ConFusion is written should follow a few basic guidelines to ensure readability and internal consistency.
If you plan on contributing code (however unlikely), please follow this guide!!

For anything not listed here you should follow [Kampfkarren's styleguide](https://github.com/Kampfkarren/kampfkarren-luau-guidelines). It's pretty similar to what I had in mind for ConFusion's styleguide, with the exception (and addition) of some things that I have explicity pointed out here.

## ConFusion's Casing Conventions
Case conventions are always a hard thing to pin down. It feels like anyone that has ever touched a keyboard has some unique way of utilizing cases in their code (unless you've had it beat out of you from using a certain programming language...).
Setting a standard for case conventions helps alleviate a lot of the ultimately pointless arguments over something as unimportant as where you put the capital letters in your code.

- Regular variables, including parameters/arguments, are to be named with `snake_case`.
- Constant variables are to be written in `SCREAMING_SNAKE_CASE`/`CONSTANT_CASE`.
- Properties of a class/table should be written in `snake_case`, optionally with a preceding underscore (`_`) to denote that it's private.
- All functions* AND methods are to be written in `camelCase`, optionally with a preceding underscore (`_`) to denote that it's private.
- Classes and types are to be written in `PascalCase`.

It's okay to slightly deviate from these conventions, cause they are just that, conventions, but it'd be really appreciated if you did follow these as having a consistent style for a project is nice, and makes it look clean and modern and blah blah whatever.

### Casing Exceptions
With any ~~great~~ terrible standard there are, of course, exceptions. Here are some of the exceptions that are permitted and expected.
- All constructor functions **MUST** be in `PascalCase` and have the same name as their class. (i.e. `Value`. `createValue` or `value` is not acceptable!)
- Some functions **MAY** be named in `PascalCase` **IF** they're directly accessible from the export table. This usually implies that the function has some interesting syntax/usage, but doesn't have to. (i.e. `Safe`, `New`, `Hydrate` etc.)

## Require Structure
Each file should define all of it's imports at the top of the file, with imports for types specifically at the very very top of the file.
Also, all imports have to be relative (for now) string imports! No requiring through the DataModel, as it's incredibly messy and generally unsafe.

Example:
```luau
local some_types = require "..."
local some_more_types = require "..."

local someUtilityFunction = require "..."
local someOtherUtility = require "..."

-- rest of the file...
```

> [!NOTE]
> Files that utilize Roblox services should define the services before any requires! Services take precedence over requires, in terms of where they are in the file structure.

## Structuring Classes
Classes should always be structured like so:
```luau
type Self = ...

local CLASS = table.freeze {
	-- [static class properties]
	type = "Example",
	kind = "example",
	
	-- [static class methods]
	doSomething = function(self: Self, ...)
		...
	end
}
local METATABLE = table.freeze { __index = CLASS }

-- object constructor function
local function Example(...): Example
	local new_example = setmetatable({}, METATABLE)
	
	return new_example
end
```

This structure is pretty well defined, it keeps the constructor separate from the methods and is relatively rigid. Although it may seem a little backwards to have the methods defined before the constructor, I think it's perfectly fine here (unless your methods need to access the constructor for whatever reason).

## Use string and table call syntax if you want!!
This one is kind of a given, since Fusion (and by extension ConFusion) is built around this syntax. While, yes this syntax can be quite cursed, it can improve the readability (and aesthetic) of your code (if that's something you really care about).