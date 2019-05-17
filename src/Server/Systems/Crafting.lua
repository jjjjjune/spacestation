local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local Recipes = import "Shared/Data/Recipes"
local Store = import "Shared/State/Store"
local SetItemPosition = import "Shared/Actions/Inventories/SetItemPosition"
local Replicate, ReplicateTo = import("Shared/State/Replication", { "replicate", "replicateTo" })
local Immutable = import "Immutable"

local function getInventory(player)
	local state = Store:getState()
	local inventory = Immutable.copy(state.inventories[tostring(player.UserId)])
	return inventory
end

local function craft(player, makes)
	local slots = {"200","201","202","203"}
	local id = tostring(player.UserId)
	for i = 1, 4 do
		local usedSlot = slots[i]
		if usedSlot then
			Store:dispatch(ReplicateTo(player, SetItemPosition(id, nil, usedSlot)))
		end
	end
	for i, item in pairs(makes)do
		Store:dispatch(ReplicateTo(player, SetItemPosition(id, item, (199+i).."" )))
	end
	Messages:send("PlaySound","GoodCraft", player.Character.HumanoidRootPart.Position)
end

local function attemptCraft(player)
	local slots = {"200","201","202","203"}
	local inventory = getInventory(player)

	local function doesHaveItem(itemName)
		for _, slot in pairs(slots) do
			local item = inventory[slot]
			if item == itemName then
				return slot
			end
		end
	end

	local function countCraftingItems()
		local count = 0
		local inv = getInventory(player)
		for i, v in pairs(slots) do
			if inv[v] then
				count = count +1
			end
		end
		return count
	end

	for _, recipe in pairs(Recipes) do
		local makes = recipe.makes
		local ingredients = recipe.recipe
		local found = 0

		for i, ingredient in pairs(ingredients) do
			if ingredient ~= nil then
				local index = doesHaveItem(ingredient)
				if index then
					found = found + 1
					inventory[index] = nil
				end
			end
		end

		if found == #ingredients and countCraftingItems() == #ingredients then
			craft(player, makes)
			return true
		else
			inventory = getInventory(player) -- reset the inventory to check the next recipe
		end
	end
end

local Crafting = {}

function Crafting:start()
	Messages:hook("Craft", function(player)
		if attemptCraft(player) then
		else
			Messages:send("PlaySound","MineStone", player.Character.HumanoidRootPart.Position)
		end
	end)
end

return Crafting
