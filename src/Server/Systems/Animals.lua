local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local MONSTER_RESPAWN_TIME = 20

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
		monster.Humanoid:SetStateEnabled("Swimming", false)
		monster.Humanoid.Died:connect(function()
			behavior:onDied()
			wait(MONSTER_RESPAWN_TIME)
			spawnClone.Parent = workspace
			setupMonster(spawnClone, tags[spawnClone.Name])
		end)
	end
end

local Animals = {}

function Animals:start()
	for tagName, scripts in pairs(tags) do
		for i, model in pairs(CollectionService:GetTagged(tagName)) do
			setupMonster(model, scripts)
		end
	end
end

return Animals
