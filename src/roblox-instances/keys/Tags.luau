local calc = require("../../core-calc/types")
local memory = require("../../core-memory/types")

local peek = require("../../core-use/peek")

local observe_immediate = require("../../core-graph/observe_immediate")

local SpecialKey = require("./SpecialKey")

local Tags = SpecialKey(
	"self",
	"Tags",
	function(scope: memory.Scope, apply_to: Instance, tags_value: calc.UsedAs<{ string }>)
		local new_tags: { [string]: boolean } = {}
		local old_tags: { [string]: boolean } = {}

		local function update_tags()
			for _, tag in peek(tags_value) do
				apply_to:AddTag(tag)

				new_tags[tag] = true
				old_tags[tag] = nil
			end

			for old_tag in old_tags do
				apply_to:RemoveTag(old_tag)
			end

			new_tags, old_tags = old_tags, new_tags
		end

		observe_immediate(scope, tags_value, update_tags)
	end
)

return Tags
