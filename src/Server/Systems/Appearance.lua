local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local Players = game:GetService("Players")
local TeamData = import "Shared/Data/TeamData"
local PhysicsService = game:GetService("PhysicsService")

PhysicsService:CreateCollisionGroup("CharacterGroup")
PhysicsService:CollisionGroupSetCollidable("Fake","CharacterGroup", false)

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

local storedHats = {}

local function toggleHelmet(character)
	if character:FindFirstChild("SpacemanHelm") then
		character["SpacemanHelm"]:Destroy()
		if storedHats[character] then
			for _, hat in pairs(storedHats[character]) do
				hat.Parent = character
				character.Humanoid:AddAccessory(hat)
			end
		end
		character.Humanoid.NameDisplayDistance = 30
	else
		if not storedHats[character] then
			storedHats[character] = {}
		end
		for _, accessory in pairs(character:GetChildren()) do
			if(accessory:FindFirstChild("HairAttachment", true) or accessory:FindFirstChild("HatAttachment", true)) and accessory:IsA("Accessory") then
				table.insert(storedHats[character], accessory)
				accessory.Parent = game.ServerStorage
			end
		end
		local hat = game.ReplicatedStorage.Assets.Hats["SpacemanHelm"]:Clone()
		hat.Parent = character
		character.Humanoid:AddAccessory(hat)
		character.Humanoid.NameDisplayDistance = 0
	end
end

local Appearance = {}

function Appearance:start()
	Players.PlayerAdded:connect(function(player)
		player.CharacterAdded:connect(function(character)
			Messages:send("CharacterAdded", player, character)
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
					PhysicsService:SetPartCollisionGroup(p, "CharacterGroup")
				end
			end)
			for _, p in pairs(character:GetChildren()) do
				if p:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(p, "CharacterGroup")
					p.Locked = false
				end
			end
			character:WaitForChild("Humanoid").Died:connect(function()
				Messages:send("PlayerDied", player)
				Messages:send("CharacterDied", character)
			end)
		end)
	end)
	Messages:hook("ApplyTeamAppearance", function(player, character)
		applyTeamAppearance(player, character)
	end)
	Messages:hook("ToggleHelmet", function(player)
		toggleHelmet(player.Character)
	end)
end

return Appearance


--[[
	http://www.roblox.com/asset/?id=891621366
	http://www.roblox.com/asset/?id=891639666
]]
