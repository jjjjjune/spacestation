local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")

local ENVIORMENTS = {
	{
		name = "Spawn greenling on plants",
		alive = {},
		limit = 2,
		checkDebounce = 180,

		asset = game.ReplicatedStorage.Assets.Animals["Greenling"],
		getAnimalSpawnPos = function()
			local plants = CollectionService:GetTagged("Plant")
			return plants[math.random(1, #plants)].Base.Position + Vector3.new(0,3,0)
		end,
	},
	{
		name = "Spawn blueling on machines",
		alive = {},
		limit = 2,
		checkDebounce = 240,

		asset = game.ReplicatedStorage.Assets.Animals["Blueling"],
		getAnimalSpawnPos = function()
			local plants = CollectionService:GetTagged("Machine")
			return plants[math.random(1, #plants)].Base.Position + Vector3.new(0,3,0)
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
				if #enviorment.alive < enviorment.limit then
					local clone = enviorment.asset:Clone()
					clone.Parent = workspace
					local pos = enviorment.getAnimalSpawnPos()
					clone:SetPrimaryPartCFrame(CFrame.new(pos))
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
