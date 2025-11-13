local function findBoundingKeys(
	eval_alpha: number,
	keyframes: { any }
): (number?, number?)
	local low_key, high_key = -math.huge, math.huge

	for alpha_key in keyframes do
		if alpha_key <= eval_alpha and alpha_key > low_key then
			low_key = alpha_key
		end

		if alpha_key >= eval_alpha and alpha_key < high_key then
			high_key = alpha_key
		end
	end

	if low_key == -math.huge then
		low_key = nil
	end

	if high_key == math.huge then
		high_key = nil
	end

	return low_key, high_key
end

return findBoundingKeys
