local import = require(game.ReplicatedStorage.Shared.Import)
local Store = import "Shared/State/Store"
local PlayerData = import "Shared/PlayerData"
local WeaponData = import "Shared/Data/WeaponData"
local EquipmentConstants = import "Shared/Data/EquipmentConstants"

local function getEquipmentSlot(inventory, tagName)
	local slotNumber = "1"
	for slot, data in pairs(EquipmentConstants.SLOT_EQUIPMENT_DATA) do
		if data.tag == tagName then
			slotNumber = slot
		end
	end
	return inventory[slotNumber]
end

local function getInventory(player)
	local state = Store:getState()
	local inventory = state.inventories[tostring(player.UserId)]
	return inventory
end

local function getWeaponData(player)
	local inventory = getInventory(player)
	local sword = getEquipmentSlot(inventory, "Sword")
	return WeaponData[sword] or WeaponData["Default"]
end

return function(player)
	local mask = PlayerData:get(player, "idol")
	local damage = getWeaponData(player).damage
	local modifier = 1
	if mask == "Mask Of Brutality" then
		modifier = 1.5
	end
	return damage*modifier
end
