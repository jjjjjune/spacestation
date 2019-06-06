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
	Banana = {
		consumable = true,
		hunger = 15,
		thirst = 15,
		eatSound = "Eating",
	},
	["Cactus Fruit"] = {
		consumable = true,
		hunger = 15,
		thirst = 35,
	},
	["Green Mushroom"] = {
		consumable = true,
		hunger = 12,
		thirst = 0,
		poison = true,
		poisonLength = 120,
	},
	["Antipoison"] = {
		consumable = true,
		hunger = 0,
		thirst = 25,
		clearPoison = true
	},
	["Red Mushroom"] = {
		consumable = true,
		hunger = 12,
		thirst = 0,
		health = 8,
	},
	["Nectar"] = {
		consumable = true,
		hunger = 5,
		thirst = 5,
		health = 3,
	},
	["Droolabou Meat"] = {
		consumable = true,
		hunger = 15,
		thirst = 1,
		health = 2,
	},
	Blueprint = {
		blueprint = true,
	},
	["Enchanted Blueprint"] = {
		blueprint = true,
	},
	["Apple Seed"] = {
		plant = "Apple Tree"
	},
	["Acorn"] = {
		plant = "Small Tree"
	},
	["Hemp Seed"] = {
		plant = "Hemp",
	},
	["Banana Seed"] = {
		plant = "Banana Tree",
	},
	["Compost"] = {
		plantGrow = 1,
	},
	["Bandage"] ={
		health = 8,
	},
	["Cactus Egg"] = {
		animal = "Cactus",
	},
	["Droolabou Egg"] = {
		animal = "Droolabou",
	},
	["Jungle Queen Egg"] = {
		animal = "Queen",
	},
	["Turtle Egg"] = {
		animal = "Turtle"
	},
	["Forgotten Idol"] = {
		class = "Forgotten",
	},
	["Brave Idol"] = {
		class = "Brave",
	},
	["Meek Idol"] = {
		class = "Meek",
	},
	["Deft Idol"] = {
		class = "Deft",
	},
	["Burned Idol"] = {
		class = "Burned",
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
