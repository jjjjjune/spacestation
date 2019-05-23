local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local Store = import "Shared/State/Store"
local EquipmentConstants = import "Shared/Data/EquipmentConstants"
local WeaponData = import "Shared/Data/WeaponData"
local GetMineModifier = import "Shared/Utils/GetMineModifier"
local GetChopModifier = import "Shared/Utils/GetChopModifier"

local CollectionService = game:GetService("CollectionService")

local ResourceCollection = {}

local function getInventory(player)
	local state = Store:getState()
	local inventory = state.inventories[tostring(player.UserId)]
	return inventory
end

local function getEquipmentSlot(inventory, tagName)
	local slotNumber = "1"
	for slot, data in pairs(EquipmentConstants.SLOT_EQUIPMENT_DATA) do
		if data.tag == tagName then
			slotNumber = slot
		end
	end
	return inventory[slotNumber]
end

local function getWeaponData(player)
	local inventory = getInventory(player)
	local sword = getEquipmentSlot(inventory, "Sword")
	return WeaponData[sword] or WeaponData["Default"]
end

local function getNearbyPlants(player)
	local plants = {}
	local character = player.Character
	local origin = Vector3.new(0,10000000,0)
	if character then
		if character:FindFirstChild("HumanoidRootPart") then
			origin = character.HumanoidRootPart.Position
		end
	end
	for _, plant in pairs(CollectionService:GetTagged("Plant")) do
		if CollectionService:HasTag(plant, "Finished") then
			if (plant.Base.Position - origin).magnitude < 12 then
				table.insert(plants, plant)
			end
		end
	end
	return plants
end

local function getNearbyRocks(player)
	local plants = {}
	local character = player.Character
	local origin = Vector3.new(0,10000000,0)
	if character then
		if character:FindFirstChild("HumanoidRootPart") then
			origin = character.HumanoidRootPart.Position
		end
	end
	for _, rock in pairs(CollectionService:GetTagged("Rock")) do
		if (rock.Base.Position - origin).magnitude < 12 and rock:IsDescendantOf(workspace) then
			table.insert(plants, rock)
		end
	end
	return plants
end

local function attemptSwing(player)
	local weaponData = getWeaponData(player)
	local trees = getNearbyPlants(player)
	local chopPower = weaponData.chopPower* GetChopModifier(player)
	if #trees > 0 then
		Messages:send("PlaySound", "Chop", player.Character.HumanoidRootPart.Position)
	end
	local inventory = getInventory(player)
	local sword = getEquipmentSlot(inventory, "Sword")
	local foundTree = false
	for _, tree in pairs(trees) do
		tree.Health.Value = tree.Health.Value - chopPower
		foundTree = true
		if tree.Health.Value == 0 then
			Messages:send("ChopPlantServer",player, tree)
		end
	end
	if foundTree then
		if sword ~= nil then
			Messages:send("PlayParticle", "Sparks",20,player.Character[sword].Base.Position)
		else
			Messages:send("PlayParticle", "Sparks",20,player.Character.Head.Position)
		end
	end
	local rocks = getNearbyRocks(player)
	if #rocks > 0  then
		Messages:send("PlaySound", "Chop", player.Character.HumanoidRootPart.Position)
	end
	local foundRock = false
	local minePower = weaponData.minePower * GetMineModifier(player)
	for _, rock in pairs(rocks) do
		rock.Health.Value = rock.Health.Value - minePower
		foundRock= true
		if rock.Health.Value == 0 then
			Messages:send("ChopRockServer",player, rock)
		end
	end
	if foundRock then
		if sword ~= nil then
			Messages:send("PlayParticle", "Sparks",20,player.Character[sword].Base.Position)
		else
			Messages:send("PlayParticle", "Sparks",20,player.Character.Head.Position)
		end
	end
end

function ResourceCollection:start()
	Messages:hook("Swing", function(player)
		spawn(function()
			wait(.3)
			attemptSwing(player)
		end)
	end)
end

return ResourceCollection


