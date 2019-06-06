local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

return function (_, buildingName, position)
	if typeof(position) == "Instance" then
		local pos = position.Character.Head.Position
		local r = Ray.new(pos, Vector3.new(0,-20,0))
		hit, pos = workspace:FindPartOnRay(r, position.Character)
		position = pos
	end
	Messages:send("MakeBuildingInstantly", buildingName, position)
	return "yea"
end
