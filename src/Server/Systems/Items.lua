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
local DESPAWN_TIME = 60

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
		error"no item found"
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
	if myHunger >= 100 and consumableData.thirst == 0 and (not consumableData.health) then
		return false
	end
	myHunger = math.min(100, myHunger + consumableData.hunger)
	Store:dispatch(ReplicateTo(player, SetHunger(userId, myHunger)))

	local myThirst = state.playerStats[userId].thirst
	if myThirst >= 100 and (not consumableData.health) then
		return false
	end
	myThirst = math.min(100, myThirst + consumableData.thirst)
	Store:dispatch(ReplicateTo(player, SetThirst(userId, myThirst)))

	if consumableData.health then
		player.Character.Humanoid.Health = player.Character.Humanoid.Health + consumableData.health
	end

	if consumableData.eatSound then
		Messages:send("PlaySound", consumableData.eatSound, player.Character.Head.Position)
	end

	if consumableData.poison then
		CollectionService:AddTag(player.Character, "Poisoned")
		local bubble = import("Assets/Particles/Poison"):Clone()
		bubble.Parent = player.Character.Head
		PlayerData:set(player, "lastHit", time())
		spawn(function()
			wait(consumableData.poisonLength)
			CollectionService:RemoveTag(player.Character, "Poisoned")
			player.Character.Head.Poison:Destroy()
		end)
	end

	return true
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
	return false
end

local function createCookedItems()
	for _, item in pairs(game.ReplicatedStorage.Assets.Items:GetChildren()) do
		print(item.Name)
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

local Items = {}

function Items:start()
	createCookedItems()
	Messages:hook("UseItem", function(player, inventorySlot)
		local data = getItemData(player, inventorySlot)
		local inventory = getInventory(player)
		if data.consumable then
			if useConsumable(player, data) then
				local userId = tostring(player.UserId)
				Store:dispatch(ReplicateTo(player, SetItemPosition(userId, nil, inventorySlot)))
			end
		end
		if data.blueprint then
			Messages:sendClient(player, "SetBlueprint", inventory[inventorySlot])
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
	Messages:hook("MakeItem", function(itemName, position)
		local model = import("Assets/Items/"..itemName):Clone()
		model.Parent = workspace
		model.PrimaryPart = model.Base
		model:SetPrimaryPartCFrame(CFrame.new(position))
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
