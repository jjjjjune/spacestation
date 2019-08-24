local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")

local ENVIORMENTS = {
	{
		name = "Spawn greenling on plants",
		alive = {},
		limit = 3,
		checkDebounce = 360,

		asset = game.ReplicatedStorage.Assets.Animals["Greenling"],
		getAnimalSpawnPos = function()
			local plants = CollectionService:GetTagged("Plant")
			return plants[math.random(1, #plants)].Base.Position + Vector3.new(0,3,0)
		end,
	},
	{
		name = "Spawn weed on plants",
		alive = {},
		limit = 3,
		checkDebounce = 420,

		asset = game.ReplicatedStorage.Assets.Animals["Weed"],
		getAnimalSpawnPos = function()
			local plants = CollectionService:GetTagged("Plant")
			for i, p in pairs(plants) do
				if not p:IsDescendantOf(workspace) then
					plants[i] = nil
				end
			end
			return plants[math.random(1, #plants)].Base.Position
		end,
	},
	{
		name = "Spawn blueling on machines",
		alive = {},
		limit = 3,
		checkDebounce = 300,

		asset = game.ReplicatedStorage.Assets.Animals["Blueling"],
		getAnimalSpawnPos = function()
			local plants = CollectionService:GetTagged("Machine")
			return (plants[math.random(1, #plants)].Base.CFrame * CFrame.new(-6,0,-6)).p + Vector3.new(0,3,0)
		end,
	},
	{
		name = "Spawn orangeling on engines",
		alive = {},
		limit = 2,
		checkDebounce = 300,

		asset = game.ReplicatedStorage.Assets.Animals["Orangeling"],
		getAnimalSpawnPos = function()
			local plants = CollectionService:GetTagged("Engine")
			return plants[1].MonsterSpawn.Position
		end,
	},
}

local function enviormentsTick()
	for _, enviorment in pairs(ENVIORMENTS) do
		if not enviorment.lastCheck then
			enviorment.lastCheck = time() - 1
		else
			if time() - enviorment.lastCheck > enviorment.checkDebounce then
				enviorment.lastCheck = time()
				for i, animal in pairs(enviorment.alive) do
					if CollectionService:HasTag(animal, "Friendly") then
						table.remove(enviorment.alive, i)
					end
				end
				if #enviorment.alive < enviorment.limit then
					local clone = enviorment.asset:Clone()
					local pos = enviorment.getAnimalSpawnPos()
					clone.PrimaryPart.CFrame = CFrame.new(pos)
					clone.Parent = workspace
					table.insert(enviorment.alive, clone)
					clone.Humanoid.Died:connect(function()
						for i, monster in pairs(enviorment.alive) do
							if monster == clone then
								table.remove(enviorment.alive, i)
							end
						end
					end)
				end
			end
		end
	end
end

local MonsterSpawning = {}

function MonsterSpawning:start()
	game:GetService("RunService").Stepped:connect(function()
		enviormentsTick()
	end)
end

return MonsterSpawning
