local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Players = game:GetService("Players")

local MovementPreparation = {}

function MovementPreparation:start()
	Players.PlayerAdded:connect(function(player)
		player.CharacterAdded:connect(function(character)
			local flyPos = Instance.new("BodyPosition", character:WaitForChild("HumanoidRootPart"))
			flyPos.MaxForce = Vector3.new()
			flyPos.Name = "FlyPosition"
			local flyGyro = Instance.new("BodyGyro", character:WaitForChild("HumanoidRootPart"))
			flyGyro.MaxTorque = Vector3.new()
			flyGyro.Name = "FlyGyro"
		end)
	end)
end

return MovementPreparation
