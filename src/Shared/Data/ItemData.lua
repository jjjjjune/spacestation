local items = {
		Default = {
		category = "misc"
	},
	Apple = {
		consumable = true,
		hunger = 10,
		thirst = 1,
		eatSound = "Eating",
	},
	["Green Mushroom"] = {
		consumable = true,
		hunger = 12,
		thirst = 0,
		poison = true,
		poisonLength = 120,
	},
	["Red Mushroom"] = {
		consumable = true,
		hunger = 12,
		thirst = 0,
		health = 8,
	},
	Blueprint = {
		blueprint = true,
	}
}

local function copyTable(t)
	local x = {}
	for i, v in pairs(t) do
		x[i] = v
	end
	return x
end

for itemName, itemData in pairs(items) do
	if itemData.consumable then
		local newData = copyTable(itemData)
		if newData.hunger then
			newData.hunger = newData.hunger * 2
		end
		if newData.health then
			newData.health = newData.health * 1.5
		end
		items["Cooked "..itemName] = newData
	end
end

return items
