local function castToGraph(target)
	if
		typeof(target) == "table"
		and target.createdAt
		and target._users
		and target._using
	then
		return target
	end

	return nil
end

return castToGraph
