local function isWithin(pos, part)
	local barrier = part
	local headPos = pos
	local barrierPos = barrier.Position
	local barrierCorner1 = barrierPos - Vector3.new((barrier.Size.Z+2)/2,0,(barrier.Size.Z+2)/2)
	local barrierCorner2 = barrierPos + Vector3.new((barrier.Size.X+2)/2,0,(barrier.Size.X+2)/2)
	local x1, y1, x2, y2 = barrierCorner1.X, barrierCorner1.Z, barrierCorner2.X, barrierCorner2.Z
	if headPos.X > x1 and headPos.X < x2 then
		if headPos.Z > y1 and headPos.Z < y2 then
			if math.abs(pos.Y - part.Position.Y) < 12 then
				return true
			end
		end
	end
	return false
end


return {
	getNearestTagToPosition = function (tag, position, dist)
		local closestTag = nil
		local closestDist = dist or 1000000
		for _, obj in pairs(game:GetService("CollectionService"):GetTagged(tag)) do
			local part = obj.PrimaryPart or obj:FindFirstChild("Base")
			if dist ~= "inside" then
				if part and (part.Position - position).magnitude < closestDist then
					closestDist = (part.Position - position).magnitude
					closestTag = obj
				end
			else
				if part and isWithin(position, part) then
					closestDist = (part.Position - position).magnitude
					closestTag = obj
				end
			end
		end
		return closestTag
	end
}
