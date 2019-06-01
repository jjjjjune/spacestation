local import = require(game.ReplicatedStorage.Shared.Import)

local WorldConstants = import "Shared/Data/WorldConstants"

local CollectionService = game:GetService("CollectionService")

local World = {}

local function isDay()
	return (game.Lighting.ClockTime > WorldConstants.DAY_MIN and game.Lighting.ClockTime < WorldConstants.DAY_MAX) or false
end

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
	spawn(function()
		while wait() do
			local night = not isDay()
			for _, mask in pairs(CollectionService:GetTagged("VampireMask")) do
				if night then
					for _, p in pairs(mask:GetChildren()) do
						if p.Name == "Eye" then
							p.BrickColor = BrickColor.new("Persimmon")
							p.Material = Enum.Material.Neon
						end
					end
				else
					for _, p in pairs(mask:GetChildren()) do
						if p.Name == "Eye" then
							p.Color = Color3.new(1,1,1)
							p.Material = Enum.Material.SmoothPlastic
						end
					end
				end
			end
		end
	end)
end

return World
