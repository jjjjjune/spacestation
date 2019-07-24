local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'

local CollectionService = game:GetService("CollectionService")
local MAX_DISTANCE = 10

local Carrying = {}

local function getClosestDrawer(position)
	local closestDist = MAX_DISTANCE
	local closestDrawer = nil
	for _, drawer in pairs(CollectionService:GetTagged("Carryable")) do
		local dist = (drawer.Base.Position - position).magnitude
		if dist < closestDist then
			closestDrawer = drawer
			closestDist = dist
		end
	end
	return closestDrawer
end

function Carrying:start()

end

return Carrying
