local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local Drops = import "Shared/Data/Drops"
local WorldConstants = import "Shared/Data/WorldConstants"
local PlayerData = import "Shared/PlayerData"
local SeedsTable = import "Shared/Data/SeedsTable"

local plantsCache = {}

local function addPlant(model, type, isDefault, phase)
	local start = tick()
	if phase == 3 then
		start = tick() - 10000
		CollectionService:AddTag(model, "Finished")
	end
	table.insert(plantsCache, {
		model = model,
		phase = phase or 1,
		lastGrow = start,
		type = type,
		isDefault = isDefault
	})
	model.Parent = workspace
end

local function getPlantByModel(model)
	for i, plantTable in pairs(plantsCache) do
		if plantTable.model == model then
			return i, plantTable
		end
	end
end

local function onPlantChopped(player, type, cframe)
	local drops = Drops[type]
	for _, itemName in pairs(drops) do
		Messages:send("MakeItem", itemName, (cframe * CFrame.new(math.random(-10,10), 5, math.random(-10,10))).p)
		--[[local item = import("Assets/Items/"..itemName):Clone()
		item.Parent = workspace
		item.PrimaryPart = item.Base--]]
	end
end

local function chopPlant(player, plantModel)
	local _, tab = getPlantByModel(plantModel)
	if CollectionService:HasTag(plantModel, "Finished") then
		local cf = plantModel.Base.CFrame
		local type = tab.type
		onPlantChopped(player,type, cf)
		PlayerData:add(player, "treesCutTotal", 1)
		plantModel:Destroy()
		if tab.isDefault then
			spawn(function()
				wait(WorldConstants.PLANT_RESPAWN_TIME)
				local plantModel = import("Assets/Plants/"..type.."/1"):Clone()
				plantModel.Parent = workspace
				plantModel.PrimaryPart = plantModel.Base
				plantModel:SetPrimaryPartCFrame(cf)
				addPlant(plantModel, type, true)
			end)
		end
	end
end

local function populateDefaultSpawners()
	for _, spawner in pairs(CollectionService:GetTagged("PlantSpawner")) do
		local plantModel = import("Assets/Plants/"..spawner.Name.."/3"):Clone()
		plantModel.PrimaryPart = plantModel.Base
		plantModel:SetPrimaryPartCFrame(spawner.CFrame * CFrame.new(0,-.1,0))
		addPlant(plantModel, spawner.Name, true, 3)
		spawner:Destroy()
	end
end

local function maturedPlantTick(newModel, plantTable)
	if math.random(1, 3) == 1 then
		local seed = SeedsTable[plantTable.type]
		if seed then
			Messages:send("MakeItem",seed, plantTable.model.Base.Position)
		end
	end
end

local mainLoop = function()
	while wait() do
		for i, plantTable in pairs(plantsCache) do
			if tick() - plantTable.lastGrow > WorldConstants.PLANT_GROW_TIME then
				if plantTable.phase < 3 then
					plantTable.phase = plantTable.phase + 1
					local newModel = import("Assets/Plants/"..plantTable.type..("/"..plantTable.phase)):Clone()
					newModel.Parent = workspace
					newModel.PrimaryPart = newModel.Base
					newModel:SetPrimaryPartCFrame(plantTable.model.Base.CFrame)
					plantTable.model:Destroy()
					plantTable.model = newModel
					if plantTable.phase >= 3 then
						CollectionService:AddTag(newModel, "Finished")
						maturedPlantTick(newModel, plantTable)
					end
				end
				plantTable.lastGrow = tick()
			end
			if plantTable.model.Parent == nil then
				table.remove(plantsCache, i)
			end
		end
	end
end

local function onRockChopped(player, type, cframe)
	local drops = Drops[type]
	for _, itemName in pairs(drops) do
		Messages:send("MakeItem", itemName, (cframe * CFrame.new(math.random(-10,10), 5, math.random(-10,10))).p)
	end
end

local function chopRock(player, plantModel)
	onRockChopped(player, plantModel.Name, player.Character.Head.CFrame)
	local replacement = plantModel:Clone()
	plantModel:Destroy()
	spawn(function()
		wait(WorldConstants.PLANT_RESPAWN_TIME)
		replacement.Health.Value = replacement.Health.MaxValue
		replacement.Parent = workspace
	end)
end

local function populateRocks()
	for _, spawner in pairs(CollectionService:GetTagged("RockSpawner")) do
		local plantModel = import("Assets/Rocks/"..spawner.Name):Clone()
		plantModel.PrimaryPart = plantModel.Base
		plantModel:SetPrimaryPartCFrame(spawner.CFrame * CFrame.new(0,-.1,0))
		plantModel.Parent = workspace
		spawner:Destroy()
	end
end

local Plants = {}

function Plants:start()
	Messages:hook("ChopPlant", function(player, plantModel)
		chopPlant(player, plantModel)
	end)
	Messages:hook("ChopPlantServer", function(player, plantModel)
		chopPlant(player, plantModel)
	end)
	Messages:hook("ChopRockServer", function(player, plantModel)
		chopRock(player, plantModel)
	end)
	Messages:hook("CreatePlant", function(player, plant, position)
		print("creating plant")
		local plantModel = import("Assets/Plants/"..plant.."/1"):Clone()
		plantModel.Parent = workspace
		plantModel.PrimaryPart = plantModel.Base
		plantModel:SetPrimaryPartCFrame(CFrame.new(position))
		addPlant(plantModel, plant, false)
	end)
	Messages:hook("GrowAllPlants", function(n)
		for i, plantTable in pairs(plantsCache) do
			plantTable.phase = math.min(3, plantTable.phase + n)
			local newModel = import("Assets/Plants/"..plantTable.type..("/"..plantTable.phase)):Clone()
			newModel.Parent = workspace
			newModel.PrimaryPart = newModel.Base
			newModel:SetPrimaryPartCFrame(plantTable.model.Base.CFrame)
			plantTable.model:Destroy()
			plantTable.model = newModel
			if plantTable.phase >= 3 then
				CollectionService:AddTag(newModel, "Finished")
				maturedPlantTick(newModel, plantTable)
			end
			plantTable.lastGrow = tick()
			if plantTable.model.Parent == nil then
				table.remove(plantsCache, i)
			end
		end
	end)
	Messages:hook("GrowPlantsNear", function(position, n)
		for i, plantTable in pairs(plantsCache) do
			if (plantTable.model.Base.Position - position).magnitude < 12 then
				plantTable.phase = math.min(3, plantTable.phase + n)
				local newModel = import("Assets/Plants/"..plantTable.type..("/"..plantTable.phase)):Clone()
				newModel.Parent = workspace
				newModel.PrimaryPart = newModel.Base
				newModel:SetPrimaryPartCFrame(plantTable.model.Base.CFrame)
				plantTable.model:Destroy()
				plantTable.model = newModel
				if plantTable.phase >= 3 then
					CollectionService:AddTag(newModel, "Finished")
					maturedPlantTick(newModel, plantTable)
				end
				plantTable.lastGrow = tick()
				if plantTable.model.Parent == nil then
					table.remove(plantsCache, i)
				end
				Messages:send("PlaySound", "Flowers", newModel.Base.Position)
				Messages:send("PlayParticle","CookSmoke", 15, newModel.Base.Position)
			end
		end
	end)
	populateDefaultSpawners()
	populateRocks()
	spawn(mainLoop)
end

return Plants
