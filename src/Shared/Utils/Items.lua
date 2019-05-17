return {
	getNearestTagToPosition = function (tag, position, dist)
		local closestTag = nil
		local closestDist = dist or 1000000
		for _, obj in pairs(game:GetService("CollectionService"):GetTagged(tag)) do
			local part = obj.PrimaryPart or obj:FindFirstChild("Base")
			if (part.Position - position).magnitude < closestDist then
				closestDist = (part.Position - position).magnitude
				closestTag = obj
			end
		end
		return closestTag
	end
}
