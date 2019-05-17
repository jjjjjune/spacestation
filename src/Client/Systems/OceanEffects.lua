local import = require(game.ReplicatedStorage.Shared.Import)

local WorldConstants = import "Shared/Data/WorldConstants"

local player = game.Players.LocalPlayer
local ocean = workspace.actual_water

local OceanEffects = {}

function OceanEffects:start()
	local function getCharacterPosition()
		return player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
	end
	game:GetService("RunService").RenderStepped:connect(function()
		local pos = getCharacterPosition()
		local waterLevel = WorldConstants.WATER_LEVEL
		if pos then
			ocean.CFrame = CFrame.new(pos.X, waterLevel - 1  + math.sin(time())/2, pos.Z)
		end
	end)
end

return OceanEffects
