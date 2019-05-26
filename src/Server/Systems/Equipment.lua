local import = require(game.ReplicatedStorage.Shared.Import)
local UserInputService = game:GetService("UserInputService")
local Messages = import "Shared/Utils/Messages"
local Store = import "Shared/State/Store"
local EquipmentConstants = import "Shared/Data/EquipmentConstants"
local PlayerData = import "Shared/PlayerData"

local CollectionService = game:GetService("CollectionService")

local lastSlotContained = {}

local function getInventory(player)
	local state = Store:getState()
	local inventory = state.inventories[tostring(player.UserId)]
	return inventory
end

local function setProperty(model, property, value)
	for _, p in pairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			p[property] = value
		end
	end
end

local function unEquip(player, itemName)
	for _, item in pairs(player.Character:GetChildren()) do
		if item.Name == itemName then
			item:Destroy()
		end
	end
end

local function equip(player, item, data)
	local character = player.Character
	local itemModel = import ("Assets/Items/"..item):Clone()
	itemModel.PrimaryPart = itemModel.Base
	itemModel:SetPrimaryPartCFrame(character[data.attach].CFrame)
	itemModel.Parent = character
	local weld = Instance.new("WeldConstraint",itemModel.Base)
	weld.Part0 = itemModel.Base
	weld.Part1 = character[data.attach]
	for _, v in pairs(itemModel:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
			v.Massless = true
		end
	end
end

local function refreshEquipment(player)
	if not lastSlotContained[player] then
		lastSlotContained[player] = {}
	end
	local inventory = getInventory(player)
	local data = EquipmentConstants.SLOT_EQUIPMENT_DATA
	for slot, equipData in pairs(data) do
		local equippedItem = inventory[slot]
		local lastEquippedItem =lastSlotContained[player][slot]
		if equippedItem ~= lastEquippedItem then
			-- if your currently equipped item is different than the last one you had equipped
			if lastEquippedItem ~= nil then
				-- if the last item you had equipped is not nil
				unEquip(player, lastEquippedItem)
				-- unequip so your new one can be equipped
				lastSlotContained[player][slot] = nil
			end
		end
	end
	for slot, equipData in pairs(data) do
		local equippedItem = inventory[slot]
		local lastEquippedItem =lastSlotContained[player][slot]
		if equippedItem ~= nil and (equippedItem ~= lastEquippedItem) then
			equip(player, equippedItem, equipData)
		end
		lastSlotContained[player][slot] = equippedItem
	end
end

local function weldBetween(a, b)
	if not a or not b then return end
	local weld = Instance.new("ManualWeld")
    weld.Part0 = a
    weld.Part1 = b
    weld.C0 = CFrame.new()
    weld.C1 = b.CFrame:inverse() * a.CFrame
	weld.Name = "Weld"
    weld.Parent = b
	return weld
end

local function autoWeld(model)
	for i, v in pairs(model:GetChildren()) do
		if v:IsA("BasePart") then
			weldBetween(v, model.Base)
		end
	end
	for i, v in pairs(model:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = false
		end
	end
end

local function updateMask(player, mask)
	if mask then
		local character = player.Character
		if character:FindFirstChild("Mask") then
			character.Mask:Destroy()
		end
		local maskModel = game.ReplicatedStorage.Assets.Idols[mask]:Clone()
		maskModel.PrimaryPart = maskModel.Base
		maskModel:SetPrimaryPartCFrame(character.Head.CFrame)
		maskModel.Name = "Mask"
		autoWeld(maskModel)
		local x = Instance.new("WeldConstraint", character.Head)
		x.Part0 = maskModel.Base
		x.Part1 = character.Head
		setProperty(maskModel, "Anchored", false)
		maskModel.Parent = character
	end
end

local Equipment = {}

function Equipment:start()
	Messages:hook("OnMaskUpdated", function(player)
		local mask = PlayerData:get(player, "idol")
		updateMask(player, mask)
	end)
	Messages:hook("OnInventoryUpdated",function(player)
		spawn(function()
			if not player.Character then
				repeat wait() until player.Character
			end
			refreshEquipment(player)
		end)
	end)
	Messages:hook("CharacterAdded", function(player, character)
		lastSlotContained[player] = nil
		refreshEquipment(player)
		local mask = PlayerData:get(player, "idol")
		updateMask(player, mask)
	end)
end

return Equipment
