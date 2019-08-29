local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")
local PlayerData = import "Shared/PlayerData"

PhysicsService:CreateCollisionGroup("AnimalGroup")
--PhysicsService:CollisionGroupSetCollidable("CharacterGroup","AnimalGroup", true)
PhysicsService:CollisionGroupSetCollidable("Default","AnimalGroup", true)
PhysicsService:CollisionGroupSetCollidable("AnimalGroup","AnimalGroup", false)
PhysicsService:CollisionGroupSetCollidable("AnimalGroup","Fake", false)
PhysicsService:CollisionGroupSetCollidable("AnimalGroup","CharacterGroup", false)

local tags = {
	["Greenling"] = {
		"Greenling"
	},
	["Blueling"] = {
		"Blueling",
	},
	["Orangeling"] = {
		"Orangeling"
	},
	["Weed"] = {
		"Weed"
	},
}

local function setupMonster(monster, scripts)
	for _, scriptName in pairs(scripts) do
		local behavior = import("Server/AnimalBehaviors/"..scriptName).new(monster)
		behavior:init()
		behavior:onSpawn()
		if monster:IsA("Model") then
			monster:MoveTo(monster.HumanoidRootPart.Position)
			monster.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
			CollectionService:AddTag(monster, "Animal")
			for _, p in pairs(monster:GetChildren()) do
				if p:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(p, "AnimalGroup")
				end
			end
			monster.Humanoid.Died:connect(function()
				behavior:onDied()
			end)
			Messages:sendAllClients("SetupAnimalClient", monster)
		end
	end
end

local function spawnAnimal(player, tagName, position)
	local model = game.ReplicatedStorage.Assets.Animals[tagName]:Clone()
	local scripts = tags[tagName]
	local monster = model
	for _, scriptName in pairs(scripts) do
		monster.Parent = workspace
		monster.HumanoidRootPart.CFrame = CFrame.new(position)
		local behavior = import("Server/AnimalBehaviors/"..scriptName).new(monster)
		behavior:init()
		behavior:onSpawn()
		monster.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
		CollectionService:AddTag(monster, "Animal")
		for _, p in pairs(monster:GetChildren()) do
			if p:IsA("BasePart") then
				PhysicsService:SetPartCollisionGroup(p, "AnimalGroup")
			end
		end
		monster.Humanoid.Died:connect(function()
			behavior:onDied()
		end)
		Messages:sendAllClients("SetupAnimalClient", monster)
	end
end

local Animals = {}

function Animals:start()
	for tagName, scripts in pairs(tags) do
		for i, model in pairs(CollectionService:GetTagged(tagName)) do
			if model:IsDescendantOf(workspace) then
				setupMonster(model, scripts)
			end
		end
		CollectionService:GetInstanceAddedSignal(tagName):connect(function(model)
			if model:IsDescendantOf(workspace) then
				setupMonster(model, scripts)
			end
		end)
	end

	Messages:hook("OnSucessfulTame",function(player, animal)
		local pos = animal.PrimaryPart.Position
		Messages:send("PlayParticle", "Hearts", 8, pos)
		Messages:send("PlaySound", "Chime", pos)
		CollectionService:AddTag(animal, "Friendly")
		CollectionService:AddTag(animal, "Following")
		for _, v in pairs(animal:GetChildren()) do
			if v.Name == "Star" then
				v.BrickColor = BrickColor.new("Shamrock")
			end
		end
		PlayerData:add(player, "animalsTamed", 1)
		PlayerData:add(player, animal.Name:lower().."Tamed",1)
	end)

	Messages:hook("ToggleFollowing", function(player, animal)
		if CollectionService:HasTag(animal, "Following") then
			CollectionService:RemoveTag(animal, "Following")
		else
			CollectionService:AddTag(animal, "Following")
		end
	end)

	Messages:hook("OnFailedTame",function(player, animal)
		local pos = animal.PrimaryPart.Position
		Messages:send("PlayParticle", "Angry", 8, pos)
		Messages:send("PlaySound", "Error", pos)
	end)

	Messages:hook("SpawnAnimal", function(player, tagName, position)
		spawnAnimal(player, tagName, position)
	end)
end

return Animals
