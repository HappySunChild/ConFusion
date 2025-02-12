local function isSimilar(a: any, b: any)
	if a ~= b then
		return false
	end
	
	if typeof(a) == 'table' then
		for key, value in a do
			if not isSimilar(value, b[key]) then
				return false
			end
		end
		
		for key, value in b do
			if not isSimilar(a[key], value) then
				return false
			end
		end
	end
	
	return true
end

return isSimilar