local import = require(game.ReplicatedStorage.Shared.Import)

local WorldConstants = import "Shared/Data/WorldConstants"

local CollectionService = game:GetService("CollectionService")

local World = {}

function World:start()
	for _, kill in pairs(CollectionService:GetTagged("Instakill")) do
		kill.Touched:connect(function(hit)
			if hit.Parent:FindFirstChild("Humanoid") then
				hit.Parent.Humanoid.Health = 0
			end
		end)
	end
	spawn(function()
		while wait(WorldConstants.WATER_REGEN_TIME) do
			for _, water in pairs(CollectionService:GetTagged("Water")) do
				water.Quantity.Value= water.Quantity.Value + 1
			end
		end
	end)
end

return World
