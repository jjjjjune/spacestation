local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Players = game:GetService("Players")
local TeamData = import "Shared/Data/TeamData"

local function applyTeamAppearance(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	local description = humanoid:GetAppliedDescription()
	description.ClimbAnimation = "rbxassetid://1090134016"
	description.FallAnimation = "rbxassetid://1090132063"
	description.IdleAnimation = "rbxassetid://1090133099"
	description.JumpAnimation = "rbxassetid://1090132507"
	description.RunAnimation = "rbxassetid://1090130630"
	description.SwimAnimation = "rbxassetid://1090133583"
	description.WalkAnimation = "rbxassetid://1090131576"
	description.WidthScale = .8
	description.HeightScale = 1.2
	wait()
	for partName, id in pairs(TeamData[player.Team.Name].bodyParts) do
		description[partName] = id
	end
	humanoid:ApplyDescription(description)
end

local Appearance = {}

function Appearance:start()
	Players.PlayerAdded:connect(function(player)
		player.CharacterAdded:connect(function(character)
			applyTeamAppearance(player, character)
			--humanoid:BuildRigFromAttachments()
			character:WaitForChild("Health"):Destroy()
			local light = Instance.new("PointLight", character.PrimaryPart)
			light.Brightness = 0
			light.Range = 12
			light.Shadows = true
			character.ChildAdded:connect(function(p)
				if p:IsA("BasePart") then
					p.Locked = false
				end
			end)
			for _, p in pairs(character:GetChildren()) do
				if p:IsA("BasePart") then
					p.Locked = false
				end
			end
		end)
	end)
	Messages:hook("ApplyTeamAppearance", function(player, character)
		applyTeamAppearance(player, character)
	end)
end

return Appearance


--[[
	http://www.roblox.com/asset/?id=891621366
	http://www.roblox.com/asset/?id=891639666
]]
