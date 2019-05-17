local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local BuildData = import "Shared/Data/BuildData"
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local BuildingItemFunctions = import "Shared/Data/BuildingItemFunctions"

local schematicsTable = {}
local modelOwnerMap = {}
local SCHEMATICS_LIMIT = 10

local function countSchematics(player)
	local count = 0
	for _, schematic in pairs(CollectionService:GetTagged("Schematic")) do
		if CollectionService:HasTag(schematic, player.Name.."Owned") then
			count = count + 1
		end
	end
	return count
end

local function setProperty(model, property, value)
	for _, p in pairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			p[property] = value
		end
	end
end

local function addRecipe(model)
	local recipe = BuildData[model.Name].recipe
	local recipeDisplay = (import "Assets/BuildingAssets/BuildingCanvas"):Clone()
	recipeDisplay.Parent = model.Base
	recipeDisplay.Adornee = model.Base
	local completeFolder = Instance.new("Folder", model)
	completeFolder.Name = "Progress"
	for item, amount in pairs(recipe) do
		local display = recipeDisplay.TemplateFrame:Clone()
		display.Parent = recipeDisplay
		display.Visible = true
		display.Label.Text = item.." x"..amount
		display.Name = item
		for _ = 1, amount do
			local itemCounter = Instance.new("BoolValue", completeFolder)
			itemCounter.Name = item
		end
	end
end

local function checkWeld(building)
	local r = Ray.new(building.Base.Position, Vector3.new(0,-10,0))
	local hit, pos = workspace:FindPartOnRay(r, building)
	if hit then
		local hitBuilding = hit.Parent
		if CollectionService:HasTag(hitBuilding, "Building") then
			if hit.Anchored == false then
				setProperty(building, "Anchored", true)
				setProperty(building, "CanCollide", false)
				for _, p in pairs(building:GetChildren()) do
					if p.Name ~= "Base" and p:IsA("BasePart") then
						local w = Instance.new("WeldConstraint", p)
						w.Part0 = p
						w.Part1 = building.Base
					end
				end
				local attachWeld = Instance.new("WeldConstraint", building.Base)
				attachWeld.Part0 = building.Base
				attachWeld.Part1 = hit
				setProperty(building, "CanCollide", true)
				setProperty(building, "Anchored", false)
				setProperty(building, "Massless", true)
			end
		end
	end
end

local function makeSchematic(model)
	for _, p in pairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			if p.Name ~= "Base" then
				p.Transparency =.9
			else
				p.Transparency = 0
			end
		end
	end
	setProperty(model, "Anchored", true)
	setProperty(model, "CanCollide", false)
	addRecipe(model)
end

local function effect(instance)
	local tweenInfo = TweenInfo.new(
		.1, -- Time
		Enum.EasingStyle.Quad, -- EasingStyle
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(instance, tweenInfo, {AspectRatio = 3})
	tween:Play()
	spawn(function()
		wait(.1)
		local tween = TweenService:Create(instance, tweenInfo, {AspectRatio = 2.5})
		tween:Play()
	end)
end

local function placeSchematic(player, building, cf)
	local model = game.ReplicatedStorage.Assets.Buildings[building]:Clone()
	if countSchematics(player) > SCHEMATICS_LIMIT then
		return
	end
	model.Parent = workspace
	model.PrimaryPart = model.Base
	model:SetPrimaryPartCFrame(cf)
	modelOwnerMap[model] = player
	CollectionService:AddTag(model, player.Name.."Owned")
	CollectionService:AddTag(model, "Schematic")
	makeSchematic(model)
	checkWeld(model)
end

local function refreshProgress(schematicModel, player)
	local progressFolder = schematicModel.Progress
	local ui = schematicModel.Base.BuildingCanvas
	local function countRemainingOfItem(item)
		local count = 0
		for _, itemTest in pairs(progressFolder:GetChildren()) do
			if itemTest.Name == item then
				count = count + 1
			end
		end
		return count
	end
	local itemsNeededAtAll = 0
	for _, frame in pairs(ui:GetChildren()) do
		if frame.Name ~= "TemplateFrame" and frame:IsA("Frame") then
			local n = countRemainingOfItem(frame.Name)
			local lastText = frame.Label.Text
			if n <= 0 then
				frame.Label.Text = frame.Name.." x0"
				frame.BackgroundColor3 = Color3.fromRGB(136,222,113)
			else
				frame.Label.Text = frame.Name.." x"..n
				itemsNeededAtAll = itemsNeededAtAll + 1
			end
			if frame.Label.Text ~= lastText then
				spawn(function() effect(frame.UIAspectRatioConstraint) end)
			end
		end
	end
	if itemsNeededAtAll == 0 then
		local realBuilding = game.ReplicatedStorage.Assets.Buildings:FindFirstChild(schematicModel.Name):Clone()
		realBuilding.Parent = workspace
		CollectionService:AddTag(realBuilding, "Building")
		realBuilding.PrimaryPart = realBuilding.Base
		realBuilding:SetPrimaryPartCFrame(schematicModel.Base.CFrame)

		checkWeld(realBuilding)

		CollectionService:AddTag(realBuilding, player.Name.."Owned")
		Messages:send("PlaySound", "Construct", realBuilding.Base.Position)
		Messages:send("PlayParticle", "Sparks",20,realBuilding.Base.Position)
		schematicsTable[player] = nil
		schematicModel:Destroy()
	end
end

local Buildings = {}

function Buildings:start()
	Messages:hook("PlaceSchematic", function(player, building, cf)
		placeSchematic(player, building, cf)
	end)
	Messages:hook("OnPlayerDroppedItem",function(player, itemModel, targetPos)
		for _, schematicModel in pairs(CollectionService:GetTagged("Schematic")) do
			local playerWhoOwns = modelOwnerMap[schematicModel]
			if (targetPos - schematicModel.Base.Position).magnitude < 12 then
				if schematicModel.Progress:FindFirstChild(itemModel.Name) then
					schematicModel.Progress[itemModel.Name]:Destroy()
					Messages:send("PlaySound", "Construct", schematicModel.Base.Position)
					itemModel:Destroy()
					refreshProgress(schematicModel, playerWhoOwns)
					break
				end
			end
		end
		for _, building in pairs(CollectionService:GetTagged("Building")) do
			if building.Parent == workspace then
				if (targetPos - building.Base.Position).magnitude < 12 then
					if BuildingItemFunctions[building.Name] then
						BuildingItemFunctions[building.Name](player, itemModel)
					end
				end
			end
		end
	end)
	game.Players.PlayerRemoving:connect(function(player)
		if schematicsTable[player] then
			schematicsTable[player]:Destroy()
			schematicsTable[player] = nil
		end
		for _, building in pairs(CollectionService:GetTagged("Building")) do
			if CollectionService:HasTag(building, player.Name.."Owned") then
				building:Destroy()
			end
		end
	end)
end

return Buildings
