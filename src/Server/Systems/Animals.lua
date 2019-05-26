local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local MONSTER_RESPAWN_TIME = 20
local PhysicsService = game:GetService("PhysicsService")
local WorldConstants = import "Shared/Data/WorldConstants"

PhysicsService:CreateCollisionGroup("AnimalGroup")
PhysicsService:CollisionGroupSetCollidable("CharacterGroup","AnimalGroup", true)
PhysicsService:CollisionGroupSetCollidable("Default","AnimalGroup", true)

local tags = {
	["Turtle"] = {
		"Turtle"
	},
	["Queen"] = {
		"Queen"
	},
	["Droolabou"] = {
		"Droolabou"
	}
}

--[[
	idea, monsters should literally just randomly lay eggs
	so if you want the pet you have to farm the animal forever basically
	take egg to egg altar to hatch...
]]

local function setupMonster(monster, scripts)
	local spawnClone = monster:Clone()
	for _, scriptName in pairs(scripts) do
		local behavior = import("Server/AnimalBehaviors/"..scriptName).new(monster)
		behavior:init()
		behavior:onSpawn()
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
			wait(MONSTER_RESPAWN_TIME)
			spawnClone.Parent = workspace
			setupMonster(spawnClone, tags[spawnClone.Name])
		end)
		Messages:sendAllClients("SetupAnimalClient", monster)
	end
end

local Animals = {}

function Animals:start()
	for tagName, scripts in pairs(tags) do
		for i, model in pairs(CollectionService:GetTagged(tagName)) do
			setupMonster(model, scripts)
		end
	end
	spawn(function()
		while wait(1) do
			for _, animal in pairs(CollectionService:GetTagged("Animal")) do
				local rp = animal:FindFirstChild("HumanoidRootPart")
				if rp then
					local yPos = animal:GetModelCFrame().p.Y - animal:GetModelSize().Y/2
					if yPos < (WorldConstants.WATER_LEVEL) then
						rp.Parent.Humanoid:TakeDamage(5)
					else
						rp.Parent.Humanoid.Health = rp.Parent.Humanoid.Health + .25
					end
				end
			end
		end
	end)
end

return Animals
