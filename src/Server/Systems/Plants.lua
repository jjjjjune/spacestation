local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local PlantData = import "Shared/Data/PlantData"
local TweenService = game:GetService("TweenService")
local AddCash = import "Shared/Utils/AddCash"
local PlayerData = import "Shared/PlayerData"

local tweenInfo = TweenInfo.new(
	.3, -- Time
	Enum.EasingStyle.Quad, -- EasingStyle
	Enum.EasingDirection.Out
)

local originalColorsTable = {}
local growingPlants = {}
local lastWaterDecay = time()

local WATER_DECAY_TIME = 60

local function getMaxGrowthPhase(plantName)
	local folder = game.ReplicatedStorage.Assets.Plants[plantName]
	for n = 1, 100 do
		if not folder:FindFirstChild(n.."") then
			return n - 1
		end
	end
end

local function updatePlantModel(plant)
	if plant:FindFirstChild("PlantDisplayModel") then
		local display = plant.PlantDisplayModel
		for _, p in pairs(display:GetChildren()) do
			if p:IsA("BasePart") then
				if not originalColorsTable[p] then
					originalColorsTable[p] = p.BrickColor
				end
			end
		end
		for _, p in pairs(display:GetChildren()) do
			if p:IsA("BasePart") then
				local start = originalColorsTable[p].Color
				local goal = start:lerp(BrickColor.new("Brown").Color, 1-plant.Water.Value/plant.Water.MaxValue)
				local tween = TweenService:Create(p, tweenInfo, {Color = goal})
				tween:Play()
			end
		end
		Messages:send("PlayParticle", "Leaf", 15, display.Base.Position)
	end
end

local function onWaterValueChanged(plant)
	updatePlantModel(plant)
	local p = plant.Dirt
	local start = BrickColor.new("Nougat").Color
	local goal = start:lerp(BrickColor.new("Dark taupe").Color, plant.Water.Value/plant.Water.MaxValue)
	local tween = TweenService:Create(p, tweenInfo, {Color = goal})
	tween:Play()
end

local function preparePlant(plant)
	local waterValue = Instance.new("IntConstrainedValue")
	waterValue.MaxValue = 5
	waterValue.MinValue = 0
	waterValue.Name = "Water"
	waterValue.Parent = plant
	waterValue.Value = 3
	waterValue:GetPropertyChangedSignal("Value"):connect(function()
		onWaterValueChanged(plant)
	end)
	waterValue.Value = 5
	local currentPlant = Instance.new("StringValue", plant)
	currentPlant.Name = "Plant"
	currentPlant.Parent = plant
	plant.PrimaryPart = plant.Base
end

local function onAttemptPlantSeed(player, plant, seed)
	if plant.Plant.Value == "" and plant.Water.Value > 0 then
		PlayerData:add(player, "plantsPlanted", 1)
		PlayerData:add(player, seed.Plant.Value:lower().."Planted", 1)
		local plantModel = game.ReplicatedStorage.Assets.Plants[seed.Plant.Value]["1"]:Clone()
		table.insert(growingPlants, {
			plant = plantModel,
			holder = plant,
			growthPhase = 1,
			maxGrowthPhase = getMaxGrowthPhase(seed.Plant.Value),
			lastGrow = time(),
			name = seed.Plant.Value
		})
		plant.Plant.Value = seed.Plant.Value
		plantModel.PrimaryPart = plantModel.Base
		plantModel:SetPrimaryPartCFrame(plant.Base.CFrame)
		plantModel.Name = "PlantDisplayModel"
		plantModel.Parent = plant
		Messages:send("PlayParticle", "Leaf", 15, plantModel.Base.Position)
		Messages:send("PlaySound", "Leaves", plantModel.Base.Position)
		seed:Destroy()
	else
		if plant.Water.Value == 0 then
			Messages:sendClient("Notify", player, "Needs water!")
		else
			Messages:sendClient("Notify", player, "Already something planted here!")
		end
	end
end

local function grow(plantInfoTable)
	plantInfoTable.growthPhase = plantInfoTable.growthPhase + 1
	local newPlant = game.ReplicatedStorage.Assets.Plants[plantInfoTable.name][plantInfoTable.growthPhase..""]:Clone()
	newPlant.Parent = plantInfoTable.plant.Parent
	newPlant.Name = "PlantDisplayModel"
	plantInfoTable.plant:Destroy()
	plantInfoTable.plant = newPlant
	newPlant.PrimaryPart = newPlant.Base
	newPlant:SetPrimaryPartCFrame(newPlant.Parent.PrimaryPart.CFrame)
	Messages:send("PlayParticle", "Leaf", 15, newPlant.Base.Position)
	Messages:send("PlaySound", "Leaves", newPlant.Base.Position)
	plantInfoTable.lastGrow = time()
end

local function makeHarvestable(plantInfoTable)
	local collectBox = Instance.new("Part", plantInfoTable.plant)
	collectBox.Size = Vector3.new(3,3,3)
	collectBox.Transparency = 1
	collectBox.CFrame = plantInfoTable.plant.PrimaryPart.CFrame * CFrame.new(0,3,0)
	collectBox.Anchored = true
	collectBox.Name = "CollectBox"
	local detector = Instance.new("ClickDetector", collectBox)
	Messages:send("RegisterDetector",detector, function(player)
		local contents = PlantData[plantInfoTable.name].products
		for _, productName in pairs(contents) do
			--if math.random(1,5) <= 4 then
				AddCash(player, math.random(2,3))
				local product = game.ReplicatedStorage.Assets.Objects[productName]:Clone()
				product.Parent = workspace
				product.PrimaryPart = product.Base
				product:SetPrimaryPartCFrame(plantInfoTable.plant.Base.CFrame * CFrame.new(0,3,0))
			--end
		end
		PlayerData:add(player, "plantsHarvested", 1)
		PlayerData:add(player, plantInfoTable.name:lower().."Harvested",1)
		Messages:send("PlayParticle", "Leaf", 15, collectBox.Position)
		Messages:send("PlaySound", "Leaves", collectBox.Position)
		plantInfoTable.plant.Parent.Plant.Value = ""
		plantInfoTable.plant:Destroy()
		collectBox:Destroy()
	end)
end

local Plants = {}

function Plants:start()
	for _, plant in pairs(CollectionService:GetTagged("Plant")) do
		preparePlant(plant)
	end
	Messages:hook("OnObjectReleased", function(player, object)
		for _, plant in pairs(CollectionService:GetTagged("Plant")) do
			if CollectionService:HasTag(object, "Seed") then
				if object:FindFirstChild("Base") and plant:FindFirstChild("Base") and plant:FindFirstChild("Plant") and (plant.Base.Position - object.Base.Position).magnitude < 6 then
					onAttemptPlantSeed(player, plant, object)
				end
			end
		end
	end)
	spawn(function()
		game:GetService("RunService").Stepped:connect(function()
			if time() - lastWaterDecay > WATER_DECAY_TIME then
				lastWaterDecay = time()
				for _, plant in pairs(CollectionService:GetTagged("Plant")) do
					if plant.Water.Value== 0 then
						if plant:FindFirstChild("PlantDisplayModel") then
							CollectionService:AddTag(plant.PlantDisplayModel, "Dead")
							Messages:send("PlayParticle", "Skulls", 15, plant.Base.Position)
						end
					end
					plant.Water.Value = plant.Water.Value - 1
				end
			end
			for _, plantInfoTable in pairs(growingPlants) do
				if time() - plantInfoTable.lastGrow > PlantData[plantInfoTable.name].growTime then
					if plantInfoTable.growthPhase < plantInfoTable.maxGrowthPhase then
						grow(plantInfoTable)
					else
						if not CollectionService:HasTag(plantInfoTable.plant, "Finished") then
							if not plantInfoTable.plant:FindFirstChild("CollectBox") then
								makeHarvestable(plantInfoTable)
							end
						end
						CollectionService:AddTag(plantInfoTable.plant, "Finished")
					end
				end
			end
		end)
	end)
end

return Plants
