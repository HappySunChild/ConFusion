local instances = require("../types")
local memory = require("../../core-memory/types")

local External = require("../../core-external/External")
local SpecialKey = require("../SpecialKey")
local cast_to_state = require("../../core-calc/cast_to_state")
local destroy = require("../../core-memory/destroy")
local observe = require("../../core-graph/observe")
local peek = require("../../core-use/peek")

local Tags = SpecialKey(
	"self",
	"Tags",
	function(scope: memory.Scope, apply_to: Instance, tags: instances.Tag?)
		local new_tags: { [string]: boolean }, old_tags: { [string]: boolean } = {}, {}
		local new_scopes: { [string]: memory.Scope }, old_scopes: { [string]: memory.Scope } =
			{}, {}

		local function update_tags()
			old_tags, new_tags = new_tags, old_tags
			old_scopes, new_scopes = new_scopes, old_scopes

			local function process_tag(tag: instances.Tag)
				local tag_type = typeof(tag)

				if tag_type == "string" then -- ROOT CASE
					print("root tag case")

					new_tags[tag] = true
					old_tags[tag] = nil

					apply_to:AddTag(tag)
				elseif cast_to_state(tag) ~= nil then -- STATE CASE
					local used_tag = peek(tag)

					if used_tag ~= nil then
						process_tag(used_tag)
					end

					local tag_scope = old_scopes[tag]

					if tag_scope == nil then
						tag_scope = {}
						observe(tag_scope, tag, update_tags)
					else
						old_scopes[tag] = nil
					end

					new_scopes[tag] = tag_scope
				elseif tag_type == "table" then -- NESTED CASE
					-- should this use ipairs?
					for _, subtag in tag :: { instances.Tag } do
						process_tag(subtag)
					end
				else
					External.log_error_nonfatal(
						instances.invalid_tag_type,
						debug.traceback(nil, 2),
						tag_type
					)
				end
			end

			if tags ~= nil then
				process_tag(tags)
			end

			for tag in old_tags do
				apply_to:RemoveTag(tag)
			end

			for _, scope in old_scopes do
				destroy(scope)
			end

			table.clear(old_scopes)
			table.clear(old_tags)
		end

		table.insert(scope, function()
			tags = nil

			update_tags()
		end)

		update_tags()
	end
)

return Tags
