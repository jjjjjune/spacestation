--[[
	Handles players when they join and leave the game.
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local Players = game:GetService("Players")

local Store = import "Shared/State/Store"
local Replicate, ReplicateTo = import("Shared/State/Replication", { "replicate", "replicateTo" })
local PlayerAdded = import "Shared/Actions/PlayerAdded"
local PlayerRemoving = import "Shared/Actions/PlayerRemoving"
local SetHealth = import "Shared/Actions/PlayerStats/SetHealth"
local SetMaxHealth = import "Shared/Actions/PlayerStats/SetMaxHealth"
local SetTimeAlive = import "Shared/Actions/PlayerStats/SetTimeAlive"
local Messages = import "Shared/Utils/Messages"
local GetMaxHealthModifier = import "Shared/Utils/GetMaxHealthModifier"
local Data = import "Shared/PlayerData"
local PhysicsService = game:GetService("PhysicsService")
local WorldConstants = import "Shared/Data/WorldConstants"
local CollectionService = game:GetService("CollectionService")

PhysicsService:CreateCollisionGroup("CharacterGroup")
PhysicsService:CreateCollisionGroup("RagdollGroup")
PhysicsService:CollisionGroupSetCollidable("CharacterGroup","RagdollGroup", false)
--PhysicsService:CollisionGroupSetCollidable("CharacterGroup","CharacterGroup", false)

local replicationReady = {}

local Users = {}


local function setClass(character, className)
	local classAsset = import("Assets/Races/"..className)
	local player =game.Players:GetPlayerFromCharacter(character)

	--[[for _, dec in pairs(character:GetDescendants()) do
		if dec.Name == "OriginalSize" then
			dec:Destroy()
		end
	end--]]

	local humanoidDescription = character.Humanoid.HumanoidDescription

	humanoidDescription.TorsoColor =classAsset.UpperTorso.BrickColor.Color
	humanoidDescription.LeftArmColor =classAsset.LeftUpperArm.BrickColor.Color
	humanoidDescription.RightArmColor =classAsset.RightUpperArm.BrickColor.Color
	humanoidDescription.HeadColor =classAsset.Head.BrickColor.Color
	humanoidDescription.LeftLegColor =classAsset.LeftUpperLeg.BrickColor.Color
	humanoidDescription.RightLegColor =classAsset.RightUpperLeg.BrickColor.Color
	humanoidDescription.HeadScale = classAsset.Humanoid.HeadScale.Value

	--humanoidDescription.Head = 2510332695
	humanoidDescription.RunAnimation = 2510238627
	humanoidDescription.WalkAnimation = 2510242378
	humanoidDescription.IdleAnimation = 2510235063

	character.Humanoid.MaxHealth = (classAsset.Humanoid.MaxHealth * GetMaxHealthModifier(player))
	character.Humanoid.Health = character.Humanoid.MaxHealth
	character.Humanoid.WalkSpeed = classAsset.Humanoid.WalkSpeed
	character.Humanoid.JumpPower = classAsset.Humanoid.JumpPower

	Data:set(player, "walkspeed", classAsset.Humanoid.WalkSpeed)

	local rand = Random.new(player.UserId)
	local torsoColors = {
		BrickColor.new("Bright blue"),
		BrickColor.new("Bright red"),
		BrickColor.new("Br. yellowish green"),
		BrickColor.new("Bright yellow"),
		BrickColor.new("White"),
		BrickColor.new("Black"),
	}

	humanoidDescription.TorsoColor = torsoColors[rand:NextInteger(1,#torsoColors)].Color
	character.Humanoid:ApplyDescription(humanoidDescription)

	local horns = classAsset.horns:Clone()
	horns.PrimaryPart = horns.Base
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = horns.Base
	weld.Part1 = character.Head
	horns.Base.CFrame = (character.Head.CFrame)
	weld.Parent = character.Head
	for _, v in pairs(horns:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = false
		end
	end
	horns.Parent = character

    for _, v in pairs(character:GetChildren()) do
        if v:IsA("Accessory") then
            v:Destroy()
		elseif v:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(v, "CharacterGroup")
        end
    end
    if character:FindFirstChild("Shirt") then
        character.Shirt:Destroy()
    end
    if character:FindFirstChild("Pants") then
        character.Pants:Destroy()
	end

	for _, value in pairs(classAsset.Humanoid:GetChildren()) do
        if value:IsA("NumberValue") then
            character.Humanoid[value.Name].Value = value.Value
        end
	end

	character:WaitForChild("Health"):Destroy()
	character.Humanoid.BreakJointsOnDeath = false
	local vel = Instance.new("BodyVelocity", character.HumanoidRootPart)
	vel.MaxForce = Vector3.new(0,0,0)
	spawn(function()
		wait(1)
		character.Humanoid.HeadScale.Value = classAsset.Humanoid.HeadScale.Value - .05
		character.Humanoid.BodyHeightScale.Value = classAsset.Humanoid.BodyHeightScale.Value - .05
	end)
end

local function determineRace(player)
	local races = {
		"Brave","Meek","Forgotten",
	}
	local rand = Random.new(player.UserId)
	rand = rand:NextInteger(1, #races)
	Data:set(player, "race", races[rand])
end

local function addCharacter(player, firstTime)
	Data:set(player, "lastHit",  -1000000)
	player:LoadCharacter()
	local race = Data:get(player, "race")
	setClass(player.Character, race)
	Messages:send("CharacterAdded",player,player.Character)
	CollectionService:AddTag(player.Character, "Character")
	if firstTime then
		local position = Data:get(player, "position")
		if position then
			player.Character:SetPrimaryPartCFrame(CFrame.new(position.x, position.y, position.z))
		end
	end
	player.Character:WaitForChild("Humanoid").Died:connect(function()
		spawn(function() Messages:send("PlayerDied", player) end)
		determineRace(player)
		wait(5)
		addCharacter(player)
	end)
end

local function onPlayerAdded(player)
	local race = Data:get(player, "race")
	if race == "Seed" then
		determineRace(player)
	end
	addCharacter(player, true)
end

function Users:start()
	Messages:hook("RespawnPlayer", function(player)
		if not player.Character then
			print("no cahracter some how")
		end
		local spawns = CollectionService:GetTagged("Spawn")
		player.Character:MoveTo(spawns[math.random(1, #spawns)].Position)
	end)

	Players.PlayerAdded:Connect(function(player)
		local userId = tostring(player.UserId)
		Store:dispatch(PlayerAdded(userId))
		Store:dispatch(ReplicateTo(player, PlayerAdded(userId)))
		Messages:send("PlayerAdded", player)
		Data:set(player, "lastHit", -1000000)
		onPlayerAdded(player)
	end)

	Messages:hook("PlayerHasRemoved", function(player)
		local userId = tostring(player.UserId)
		Store:dispatch(PlayerRemoving(userId))
	end)

	Messages:hook("PlayerIsRemoving",function(player)
		local lastHit = Data:get(player, "lastHit")
		if lastHit and os.time() - lastHit < WorldConstants.COMBAT_LOG_TIME then
			Messages:send("PlayerDied", player)
		end
		Messages:send("DeathCheckDone", player)
	end)

	game:GetService("RunService").Stepped:connect(function()
		for _, player in pairs(game.Players:GetPlayers()) do
			local id = tostring(player.UserId)
			local character = player.Character
			if character then
				local hum = character:FindFirstChild("Humanoid")
				if hum then
					Store:dispatch(ReplicateTo(player, SetMaxHealth(id, hum.MaxHealth)))
					Store:dispatch(ReplicateTo(player, SetHealth(id, hum.Health)))
					Store:dispatch(ReplicateTo(player, SetTimeAlive(id, Data:get(player, "timeAlive"))))
				end
			end
		end
	end)
end

return Users
