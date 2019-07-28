local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

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
	}
}

--[[
	idea, monsters should literally just randomly lay eggs
	so if you want the pet you have to farm the animal forever basically
	take egg to egg altar to hatch...
]]

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

local Animals = {}

function Animals:start()
	for tagName, scripts in pairs(tags) do
		for i, model in pairs(CollectionService:GetTagged(tagName)) do
			if model:IsDescendantOf(workspace) then
				setupMonster(model, scripts)
			end
		end
	end

	Messages:hook("SpawnAnimal", function(player, tagName, position)
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
	end)
end

return Animals
