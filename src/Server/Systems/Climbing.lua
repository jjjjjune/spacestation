local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Climbing = {}

function Climbing:start()
	Messages:hook("CharacterAdded", function(player)
		local hrp = player.Character:WaitForChild("HumanoidRootPart")
		local climbGyro = Instance.new("BodyGyro", hrp)
		climbGyro.Name = "ClimbGyro"
		climbGyro.MaxTorque = Vector3.new(0,0,0)
		local climbPos = Instance.new("BodyPosition", hrp)
		climbPos.Name = "ClimbPos"
		climbPos.MaxForce = Vector3.new(0,0,0)
	end)
end

return Climbing
