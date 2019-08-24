local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local AddCash = import "Shared/Utils/AddCash"

local tweenInfo = TweenInfo.new(
	.3, -- Time
	Enum.EasingStyle.Quad, -- EasingStyle
	Enum.EasingDirection.Out
)

local function addWater(well, amount)
	well.Water.Value = well.Water.Value + amount
end

local function canAddWater(well)
	if well.Water.Value < well.Water.MaxValue then
		return true
	end
	return false
end

local function onWaterChanged(well)
	Messages:send("PlaySound", "Drinking", well.Base.Position)
	local goalCF = well.Base.CFrame * CFrame.new(0,well.Water.Value/7,0)
	local tween = TweenService:Create(well.WaterDisplay, tweenInfo, {CFrame = goalCF})
	tween:Play()
	if well.Water.Value == 0 then
		well.WaterDisplay.Transparency = 1
		well.WaterIndicator.Decal.Texture = "rbxgameasset://Images/waterempty"
		well.WaterIndicator.BrickColor = BrickColor.new("Dusty Rose")
	else
		well.WaterDisplay.Transparency = 0
		well.WaterIndicator.Decal.Texture = "rbxassetid://3572927696"
		well.WaterIndicator.BrickColor = BrickColor.new("Olivine")
	end
end

local function onHitboxTouched(well, hit)
	print("hitbox touched")
	if CollectionService:HasTag(hit.Parent, "Water") then
		print("yeah water")
		local water = hit.Parent
		if water.Parent == workspace then
			if canAddWater(well) then
				addWater(well, 10)
				water:Destroy()
			end
		else
			print(water.Parent)
		end
	end
end

local function setupWells()
	for _, well in pairs(CollectionService:GetTagged("Well")) do
		local waterCount = Instance.new("IntConstrainedValue", well)
		waterCount.Name = "Water"
		waterCount.MinValue = 0
		waterCount.MaxValue = 10
		waterCount.Value = 0
		onWaterChanged(well)
		waterCount:GetPropertyChangedSignal("Value"):connect(function()
			onWaterChanged(well)
		end)
		well.Water.Value = 10
		local hitbox = well.Base:Clone()
		hitbox.Name = "hitbix"
		hitbox.CanCollide = false
		hitbox.Parent = well
		hitbox.Size = well.Base.Size * 2
		hitbox.Transparency = 1
		hitbox.Touched:connect(function(hit)
			if CollectionService:HasTag(hit.Parent, "Burning") then
				Messages:send("Unburn", hit.Parent)
				Messages:send("PlaySound", "Drinking", hit.Position)
				Messages:send("PlayParticle", "Water", 15, hit.Position)
			end
		end)
	end
end

local function onPlantWatered(player, plant, wateringCan)
	if plant:FindFirstChild("PlantDisplayModel") then
		if CollectionService:HasTag(plant.PlantDisplayModel, "Dead") then
			if player then
				Messages:sendClient(player, "Notify", "This plant is dead!")
			end
			return
		end
	end
	if player then
		AddCash(player, math.random(1,2))
	end

	if wateringCan then
		Messages:send("PlaySound", "Drinking", wateringCan.Handle.Position)
		wateringCan.Water.Value = wateringCan.Water.Value - 1
		if wateringCan.Water.Value == 0 then
			wateringCan.TextureId = "rbxassetid://3576099564"
			CollectionService:RemoveTag(wateringCan, "Full")
		end
	end

	plant.Water.Value = plant.Water.Value + 5
	Messages:send("PlayParticle", "Water", 15, plant.Base.Position)
end

local Water = {}

function Water:start()
	setupWells()
	Messages:hook("OnObjectReleased", function(player, object)
		for _, well in pairs(CollectionService:GetTagged("Well")) do
			if CollectionService:HasTag(object, "Water") then
				if (well.Base.Position - object.Base.Position).magnitude < 10 then
					onHitboxTouched(well, object.Base)
					AddCash(player, math.random(3,6))
					object:Destroy()
				end
			end
		end
	end)
	Messages:hook("FillWateringCan", function(player, well)
		local wateringCan = player.Character:FindFirstChild("Watering Can")
		if wateringCan then
			if not CollectionService:HasTag(wateringCan, "Full") then
				local waterAmount = well.Water.Value
				if waterAmount > 0 then
					well.Water.Value = well.Water.Value - 1
					CollectionService:AddTag(wateringCan, "Full")
					wateringCan.TextureId = "rbxassetid://3572927696"
					Messages:send("PlaySound", "Drinking", wateringCan.Handle.Position)
					Messages:sendClient(player, "Notify", "Watering can filled!")
					if not wateringCan:FindFirstChild("Water") then
						local waterVal = Instance.new("IntConstrainedValue", wateringCan)
						waterVal.Name = "Water"
						waterVal.MaxValue = 5
						waterVal.Value = 5
						waterVal.MinValue = 0
					else
						wateringCan.Water.Value = 5
					end
				else
					Messages:sendClient(player, "Notify", "Well needs more water! Get some from cargo!")
				end
			else
				Messages:sendClient(player, "Notify", "Can already full!")
			end
		end
	end)
	Messages:hook("WaterPlant", function(player, plant)
		local wateringCan = player and player.Character and player.Character:FindFirstChild("Watering Can")
		if wateringCan then
			if CollectionService:HasTag(wateringCan, "Full") then
				if plant.Water.Value < plant.Water.MaxValue then
					if wateringCan.Water.Value > 0 then
						onPlantWatered(player, plant, wateringCan)
					else
						Messages:sendClient(player, "Notify", "Watering can empty!")
					end
				else
					Messages:sendClient(player, "Notify", "Plant doesn't need water!")
				end
			else
				Messages:sendClient(player, "Notify", "Watering can empty!")
			end
		else
			if player then
				onPlantWatered(player, plant, wateringCan)
			else
				onPlantWatered(nil,plant,nil)
			end
		end
	end)
	Messages:hook("PutoutFire", function(player, object)
		local wateringCan = player and player.Character and player.Character:FindFirstChild("Watering Can")
		if wateringCan then
			if CollectionService:HasTag(wateringCan, "Full") then
				if wateringCan.Water.Value > 0 then
					--AddCash(player, math.random(1,2))
					Messages:send("Unburn", object)
					wateringCan.Water.Value = wateringCan.Water.Value - 1
					if wateringCan.Water.Value == 0 then
						wateringCan.TextureId = "rbxassetid://3576099564"
						CollectionService:RemoveTag(wateringCan, "Full")
					end
					Messages:send("PlaySound", "Drinking", wateringCan.Handle.Position)
					Messages:send("PlayParticle", "Water", 15, object.PrimaryPart.Position)
				end
			end
		else
			Messages:send("Unburn", object)
			Messages:send("PlaySound", "Drinking", object.PrimaryPart.Position)
			Messages:send("PlayParticle", "Water", 15, object.PrimaryPart.Position)
		end
	end)
end

return Water
