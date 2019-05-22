return  function (name, position, dist)
	local closestTag = nil
	local closestDist = dist or 1000000
	for _, obj in pairs(game:GetService("CollectionService"):GetTagged("Item")) do
		local part = obj.PrimaryPart or obj:FindFirstChild("Base")
		if part and (part.Position - position).magnitude < closestDist and obj.Name == name then
			closestDist = (part.Position - position).magnitude
			closestTag = obj
		end
	end
	return closestTag, closestDist
end
