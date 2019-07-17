local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Players = game:GetService("Players")

local Appearance = {}

function Appearance:start()
	Players.PlayerAdded:connect(function(player)
		player.CharacterAdded:connect(function(character)
			local humanoid = character:WaitForChild("Humanoid")
			local description = humanoid:WaitForChild("HumanoidDescription")
			description.ClimbAnimation = "rbxassetid://1090134016"
			description.FallAnimation = "rbxassetid://1090132063"
			description.IdleAnimation = "rbxassetid://1090133099"
			description.JumpAnimation = "rbxassetid://1090132507"
			description.RunAnimation = "rbxassetid://1090130630"
			description.SwimAnimation = "rbxassetid://1090133583"
			description.WalkAnimation = "rbxassetid://1090131576"
			wait()
			humanoid:ApplyDescription(description)
		end)
	end)
end

return Appearance
