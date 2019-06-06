local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local Store = import "Shared/State/Store"
local ItemData = import "Shared/Data/ItemData"
local SetHunger = import "Shared/Actions/PlayerStats/SetHunger"
local SetThirst = import "Shared/Actions/PlayerStats/SetThirst"
local SetItemPosition = import "Shared/Actions/Inventories/SetItemPosition"
local Replicate, ReplicateTo = import("Shared/State/Replication", { "replicate", "replicateTo" })
local PlayerData = import "Shared/PlayerData"

local ITEM_TAG = "Item"
local STORAGE_TAG = "Storage"
local DESPAWN_TIME = 180

local CollectionService = game:GetService("CollectionService")

local WorldItems = {}

local function getInventory(player)
	local state = Store:getState()
	local inventory = state.inventories[tostring(player.UserId)]
	return inventory
end

local function getItemData(player, slot)
	local inventory = getInventory(player)
	local item = inventory[slot]
	if not item then
		--error"no item found"
	end
	return ItemData[item] or ItemData["Default"]
end

local function getItemOfSlot(player, slot)
	local inventory = getInventory(player)
	return inventory[slot]
end

local function useConsumable(player, consumableData)
	local userId = tostring(player.UserId)
	local state = Store:getState()
	local myHunger = state.playerStats[userId].hunger
	local myThirst = state.playerStats[userId].thirst
	local didHunger = false
	local didHealth = false
	local didThirst = false
	if consumableData.hunger then
		myHunger = math.min(100, myHunger + consumableData.hunger)
		Store:dispatch(ReplicateTo(player, SetHunger(userId, myHunger)))
		didHunger = true
	end
	if consumableData.thirst then
		myThirst = math.min(100, myThirst + consumableData.thirst)
		Store:dispatch(ReplicateTo(player, SetThirst(userId, myThirst)))
		didThirst = true
	end

	if consumableData.health then
		player.Character.Humanoid.Health = player.Character.Humanoid.Health + consumableData.health
		didHealth = true
	end

	if consumableData.eatSound then
		Messages:send("PlaySound", consumableData.eatSound, player.Character.Head.Position)
	end

	if consumableData.poison then
		CollectionService:AddTag(player.Character, "Poisoned")
		local bubble = import("Assets/Particles/Poison"):Clone()
		bubble.Parent = player.Character.Head
		PlayerData:set(player, "lastHit", os.time() - consumableData.poisonLength)
		spawn(function()
			wait(math.max( 0, consumableData.poisonLength))
			CollectionService:RemoveTag(player.Character, "Poisoned")
			player.Character.Head.Poison:Destroy()
		end)
	end
	if consumableData.clearPoison then
		CollectionService:RemoveTag(player.Character, "Poisoned")
		if player.Character.Head:FindFirstChild("Poison") then
			player.Character.Head.Poison:Destroy()
		end
	end
	if didThirst or didHunger or didHealth then
		return true
	else
		return false
	end
end

local function usePlant(player, data, itemName)
	if data.plant then
		local character = player.Character
		local r = Ray.new(character.HumanoidRootPart.Position, Vector3.new(0,-10,0))
		local hit, pos = workspace:FindPartOnRay(r, character)
		if hit then
			if hit ~= workspace.Terrain then
				if hit.Anchored == true then
					Messages:send("CreatePlant", player, data.plant, pos)
					return true
				end
			end
		end
	end
	return false
end

local function isInStorage(item)
	for _, storageInstance in pairs(CollectionService:GetTagged(STORAGE_TAG)) do
		local origin = storageInstance.Base.Position
		local base = storageInstance.Base
		local range = base.Size.X
		local vec1 = (origin + Vector3.new(-range,-(range*2),-range))
		local vec2 = (origin + Vector3.new(range,(range*2),range))
		local region = Region3.new(vec1, vec2)
		local parts = workspace:FindPartsInRegion3(region,nil, 10000)
		for _, part in pairs(parts) do
			if part.Parent == item then
				return true
			end
		end
	end
	if item:FindFirstChild("Base") and item.Base.Anchored == false then
		for _, v in pairs(item.Base:GetConnectedParts()) do -- if an item is connected to an animal or player, it will no longer despawn
			if v.Parent ~= item then
				return true
			end
		end
	end
	return false
end

local function createCookedItems()
	for _, item in pairs(game.ReplicatedStorage.Assets.Items:GetChildren()) do
		local data = ItemData[item.Name]
		if data and data.consumable then
			local cookedItem = item:Clone()
			cookedItem.Name = "Cooked "..item.Name
			cookedItem.Parent = game.ReplicatedStorage.Assets.Items
			for _, p in pairs(cookedItem:GetChildren()) do
				if p:IsA("BasePart") then
					p.BrickColor = BrickColor.new("Dusty Rose")
				end
			end
		end
	end
end

local function setProperty(model, property, value)
	for _, p in pairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			p[property] = value
		end
	end
end

local function checkWeld(building)
	local r = Ray.new(building.Base.Position, Vector3.new(0,-10,0))
	local hit, pos = workspace:FindPartOnRay(r, building)
	if hit then
		local hitBuilding = hit.Parent
		--if CollectionService:HasTag(hitBuilding, "Building") then
			if hit.Anchored == false then
				setProperty(building, "Anchored", true)
				setProperty(building, "CanCollide", false)
				for _, p in pairs(building:GetChildren()) do
					if p.Name ~= "Base" and p:IsA("BasePart") and p.Name ~= "noweld" then
						local w = Instance.new("WeldConstraint", p)
						w.Part0 = p
						w.Part1 = building.Base
					end
				end
				local attachWeld = Instance.new("WeldConstraint", building.Base)
				attachWeld.Part0 = building.Base
				attachWeld.Part1 = hit
				if not CollectionService:HasTag(building, "Schematic") then
					setProperty(building, "CanCollide", true)
				end
				setProperty(building, "Anchored", false)
				setProperty(building, "Massless", true)
				return true
			else
				spawn(function()
					wait(4)
					setProperty(building, "Anchored", true)
					setProperty(building, "CanCollide", false)
				end)
			end
		--end
	end
	return false
end

local Items = {}

function Items:start()
	createCookedItems()
	Messages:hook("UseItem", function(player, inventorySlot)
		local data = getItemData(player, inventorySlot)
		local inventory = getInventory(player)
		local itemName =inventory[inventorySlot]
		if data.consumable then
			if useConsumable(player, data, itemName) then
				local userId = tostring(player.UserId)
				Store:dispatch(ReplicateTo(player, SetItemPosition(userId, nil, inventorySlot)))
			end
		end
		if usePlant(player, data, itemName) then
			local userId = tostring(player.UserId)
			Store:dispatch(ReplicateTo(player, SetItemPosition(userId, nil, inventorySlot)))
		end
		if data.blueprint then
			Messages:sendClient(player, "SetBlueprint", itemName)
		end
		if data.plantGrow then
			for _, plant in pairs(CollectionService:GetTagged("Plant")) do
				if (plant.Base.Position - player.Character.HumanoidRootPart.Position).magnitude < 12 then
					Messages:send("GrowPlantsNear", player.Character.HumanoidRootPart.Position, data.plantGrow)
					local userId = tostring(player.UserId)
					Store:dispatch(ReplicateTo(player, SetItemPosition(userId, nil, inventorySlot)))
					break
				end
			end
		end
		if data.class then
			Messages:send("SetClass", player, data.class)
			local userId = tostring(player.UserId)
			Store:dispatch(ReplicateTo(player, SetItemPosition(userId, nil, inventorySlot)))
		end
	end)
	Messages:hook("OnPlayerDroppedItem", function(player, itemModel, targetPos)
		local data = ItemData[itemModel.Name]
		if data and data.consumable then
			for _, ragdolled in pairs(CollectionService:GetTagged("Ragdolled")) do
				if (ragdolled.HumanoidRootPart.Position - targetPos).magnitude < 10 then
					local targetPlayer = game.Players:GetPlayerFromCharacter(ragdolled)
					if useConsumable(targetPlayer, data) then
						itemModel:Destroy()
					end
				end
			end
		end
	end)
	Messages:hook("MakeItem", function(itemName, position, tag, player)
		local model = import("Assets/Items/"..itemName):Clone()
		setProperty(model, "CanCollide", true)
		model.Parent = workspace
		model.PrimaryPart = model.Base
		model:SetPrimaryPartCFrame(CFrame.new(position) * CFrame.new(0,model:GetModelSize().Y/2,0))
		if checkWeld(model) then
			Messages:send("PlaySound", "Construct", model.Base.Position)
		end
		if tag then
			tag.Parent = model
		end
		if player then
			Messages:send("OnPlayerDroppedItem", player, model, position)
		end
	end)
	CollectionService:GetInstanceAddedSignal(ITEM_TAG):connect(function(item)
		if item.Parent == workspace then
			table.insert(WorldItems, {item = item, time = tick()})
		end
	end)
	for _, item in pairs(CollectionService:GetTagged(ITEM_TAG)) do
		if item.Parent == workspace then
			table.insert(WorldItems, {item = item, time = tick()})
		end
	end
	spawn(function()
		while wait(1) do
			for index, itemTable in pairs(WorldItems) do
				local model = itemTable.item
				if isInStorage(model) then
					itemTable.time = tick()
				end
				if tick() - itemTable.time > DESPAWN_TIME then
					itemTable.item:Destroy()
					table.remove(itemTable, index)
				end
			end
		end
	end)
end

return Items
