local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local BuildData = import "Shared/Data/BuildData"
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local BuildingItemFunctions = import "Shared/Data/BuildingItemFunctions"
local GetPlayerDamage = import "Shared/Utils/GetPlayerDamage"

local schematicsTable = {}
local modelOwnerMap = {}
local lastHealthsTable = {}
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

local function isAnimal(model)
	return model:FindFirstChild("Humanoid") and not game.Players:GetPlayerFromCharacter(model)
end

local function checkWeld(building)
	local r = Ray.new(building.Base.Position, Vector3.new(0,-10,0))
	local hit, pos = workspace:FindPartOnRay(r, building)
	if hit then
		local hitBuilding = hit.Parent
		if CollectionService:HasTag(hitBuilding, "Building") or isAnimal(hitBuilding) then
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
				if not CollectionService:HasTag(building, "Schematic") then
					for _, p in pairs(building:GetChildren()) do
						if p:IsA("BasePart") then
							if p.Transparency < 1 or p.Name == "Barrier" then
								p.CanCollide = true
							end
						end
					end
				end
				setProperty(building, "Anchored", false)
				setProperty(building, "Massless", true)
			end
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

local function makeSchematic(model)
	for _, p in pairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			if p.Name ~= "Base" then
				p:Destroy()
			else
				p.Transparency = 0
			end
		end
		if p:IsA("VehicleSeat") then
			p:Destroy()
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
	model.Health.MaxValue = math.min(200, model.Health.MaxValue/4)
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
		local owner = modelOwnerMap[schematicModel]

		checkWeld(realBuilding)

		CollectionService:AddTag(realBuilding, owner.Name.."Owned")
		modelOwnerMap[realBuilding] = owner
		Messages:send("PlaySound", "Construct", realBuilding.Base.Position)
		Messages:send("PlayParticle", "Sparks",20,realBuilding.Base.Position)
		schematicModel:Destroy()
	end
end

local function isWithin(pos, part)
	local barrier = part
	local headPos = pos
	local barrierPos = barrier.Position
	local barrierCorner1 = barrierPos - Vector3.new((barrier.Size.Z+2)/2,0,(barrier.Size.Z+2)/2)
	local barrierCorner2 = barrierPos + Vector3.new((barrier.Size.X+2)/2,0,(barrier.Size.X+2)/2)
	local x1, y1, x2, y2 = barrierCorner1.X, barrierCorner1.Z, barrierCorner2.X, barrierCorner2.Z
	if headPos.X > x1 and headPos.X < x2 then
		if headPos.Z > y1 and headPos.Z < y2 then
			if math.abs(pos.Y - part.Position.Y) < 12 then
				return true
			end
		end
	end
	return false
end

local function damageBuilding(building, player, damage)
	local maxHealth = building.Health.MaxValue
	if not lastHealthsTable[building] then
		lastHealthsTable[building] = maxHealth
	end
	building.Health.Value = building.Health.Value - damage
	local healthBar = building:FindFirstChild("BuildingHealth") or import("Assets/BuildingAssets/BuildingHealth"):Clone()
	healthBar.Parent = building
	healthBar.Adornee = building.Base
	healthBar.StudsOffsetWorldSpace = Vector3.new(0, building:GetModelSize().Y,0)
	healthBar.Enabled = true
	local percent = building.Health.Value/maxHealth
	healthBar.foreground:TweenSize(UDim2.new(percent,0,1,0), "Out", "Quint", .3)
	lastHealthsTable[building] = building.Health.Value
	spawn(function()
		local checkHealth = building.Health.Value
		wait(6)
		if building:FindFirstChild("Health") and building.Health.Value == checkHealth then
			healthBar.Enabled = false
		end
	end)
	if building.Health.Value == 0 then
		CollectionService:RemoveTag(building, "Building")
		for _, p in pairs(building:GetChildren()) do
			if p:IsA("BasePart") then
				p.Anchored = false
				p:BreakJoints()
			end
		end
		Messages:send("PlaySound", "Chop", player.Character.HumanoidRootPart.Position)
		game:GetService("Debris"):AddItem(building, 5)
	end
	Messages:send("PlayParticle", "Sparks",20,player.Character.Head.Position)
	Messages:send("PlaySound", "Construct", building.Base.Position)
end

local function getAngleRelativeToPlayer(character, target)
	local originPart = character.HumanoidRootPart
	local toTargetDirection = (target - originPart.Position).unit
	local targetAngle = originPart.CFrame.lookVector:Dot(toTargetDirection)
	return math.deg(math.acos(targetAngle))
end

local function getBuildings(character, range, angle)
	local buildings = {}
	local inserted = {}
	local vec1 = (character.HumanoidRootPart.Position + Vector3.new(-range,-(range*4),-range))
	local vec2 = (character.HumanoidRootPart.Position + Vector3.new(range,(range*4),range))
	local region = Region3.new(vec1, vec2)
	local parts = workspace:FindPartsInRegion3(region,nil, 10000)
	for _, part in pairs(parts) do
		if CollectionService:HasTag(part.Parent, "Building") or CollectionService:HasTag(part.Parent, "Schematic") then
			local building = part.Parent
			local ang = getAngleRelativeToPlayer(character, part.Position)
			if ang < angle then
				if not inserted[building] then
					inserted[building] = true
					table.insert(buildings, building)
				end
			end
		end
	end
	return buildings
end

local function attemptSwing(player)
	local damage = GetPlayerDamage(player)
	damage = damage/2
	local buildings = getBuildings(player.Character, 2, 80)
	for _, building in pairs(buildings) do
		if player.Character:FindFirstChild("Hammer") then
			damage= - damage
			damage = damage * 2
		elseif player.Character:FindFirstChild("Iron Hammer") then
			damage= - damage
			damage = damage * 4
		end
		if damage > 0 and CollectionService:HasTag(building, player.Name.."Owned") then
			return
		end
		damageBuilding(building, player, damage)
	end
end

local function getOwner(building)
	for _, player in pairs(game.Players:GetPlayers()) do
		if CollectionService:HasTag(building, player.Name.."Owned") then
			return player
		end
	end
end

local function checkBuildingFunctions(building)
	-- sets up the hitbox functions for a building
	if building.Parent == workspace and not CollectionService:HasTag(building, "Hooked") then
		CollectionService:AddTag(building, "Hooked")
		building.Hitbox.Touched:connect(function(hit)
			local item = hit.Parent
			if item:FindFirstChild("Base") and item.Parent == workspace then
				if BuildingItemFunctions[building.Name] then
					local player = getOwner(building)
					BuildingItemFunctions[building.Name](player, item, building)
				end
			end
		end)
	end
end

local Buildings = {}

function Buildings:start()
	Messages:hook("Swing", function(player)
		spawn(function()
			wait(.3)
			attemptSwing(player)
		end)
	end)
	Messages:hook("PlaceSchematic", function(player, building, cf)
		placeSchematic(player, building, cf)
	end)
	Messages:hook("OnPlayerDroppedItem",function(player, itemModel, targetPos)
		for _, schematicModel in pairs(CollectionService:GetTagged("Schematic")) do
			local playerWhoOwns = modelOwnerMap[schematicModel]
			if isWithin(targetPos,schematicModel.Base) then
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
				if isWithin(targetPos,building.Base) then
					if BuildingItemFunctions[building.Name] then
						BuildingItemFunctions[building.Name](player, itemModel, building)
					end
				end
			end
		end
	end)
	Messages:hook("DestroyBuilding", function(player, building)
		if CollectionService:HasTag(building, player.Name.."Owned") then
			Messages:send("PlaySound", "Destruct", building.Base.Position)
			building:Destroy()
		end
	end)
	game.Players.PlayerRemoving:connect(function(player)
		for _, building in pairs(CollectionService:GetTagged("Building")) do
			if CollectionService:HasTag(building, player.Name.."Owned") then
				building:Destroy()
			end
		end
		for _, building in pairs(CollectionService:GetTagged("Schematics")) do
			if CollectionService:HasTag(building, player.Name.."Owned") then
				building:Destroy()
			end
		end
	end)
	CollectionService:GetInstanceAddedSignal("Door"):connect(function(door)
		door.Hitbox.Touched:connect(function(hit)
			local character = hit.Parent
			if character:FindFirstChild("Humanoid") then
				if CollectionService:HasTag(door, character.Name.."Owned") then
					if door.Hitbox.CanCollide == true then
						door.Hitbox.CanCollide = false
						spawn(function()
							wait(4)
							door.Hitbox.CanCollide = true
						end)
					end
				end
			end
		end)
	end)
	for _, building in pairs(CollectionService:GetTagged("Building")) do
		if building.Parent == workspace then
			checkBuildingFunctions(building)
		end
	end
	for _, building in pairs(game.ReplicatedStorage.Assets.Buildings:GetChildren()) do
		if not building:FindFirstChild("Hitbox") and BuildingItemFunctions[building.Name] then
			local hitbox = Instance.new("Part")
			hitbox.Size = building:GetModelSize()* Vector3.new(1,2,1)
			hitbox.CFrame = building:GetModelCFrame()
			hitbox.CanCollide = false
			hitbox.Anchored = true
			hitbox.Transparency = 1
			hitbox.Name = "Hitbox"
			hitbox.Parent = building
		end
	end
	CollectionService:GetInstanceAddedSignal("Building"):connect(function(building)
		checkBuildingFunctions(building)
	end)
end

return Buildings
