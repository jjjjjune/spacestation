local QuestData = {}

QuestData.REAL_DAY = 24*60*60
QuestData.DAY = 16*60*60
QuestData.quests = {}

QuestData.quests.daily = {}
QuestData.quests.workers = {}
QuestData.quests.scientists = {}
QuestData.quests.cooks = {}
QuestData.quests.captain = {}
QuestData.quests.security = {}
QuestData.quests.botanists = {}
QuestData.quests.medics = {}

local function addQuest(subType, stat, amount, verb, reward, length, id, title)
	if id == nil then
		id = subType..stat..amount
	end
	table.insert(QuestData.quests[subType], {
		stat = stat,
		amount = amount,
		verb = verb,
		reward = reward,
		id = id,
		length = length or math.huge,
		title = title,
		isTeam = (subType ~= "daily"),
		subType = subType --this is used to store the teams of quests given to the player
	})
end

local REWARD_LOW = {
	cash = 100,
}
local REWARD_MED = {
	cash = 250,
}
local REWARD_HIGH = {
	cash = 500,
}
local REWARD_LEGENDARY = {
	cash = 2500,
}

--[[
	machinesFixed
	monsternameKilled
	greenGooFilled
	healthHealed
	foodnameCooked
	foodCooked
	itemnameExploded
	objectsExploded
	animalsTamed
	animalnameTamed
	playersArrested
	gotArrested
	plantsPlanted
	plantsHarvested
	plantnamePlanted
	plantnameHarvested
	firesPutOut
	plantsWatered
	wellsFilled
]]

addQuest("daily", "bluelingKilled", 25 , " bluelings defeated",REWARD_HIGH,math.huge,"dailyworker2", "blueling conquerer")
addQuest("daily", "weedTamed", 25 , " weeds tamed",REWARD_HIGH,math.huge,"dailyscience2", "weed friend maker")
addQuest("daily", "doughCooked", 65 , " foods cooked",REWARD_HIGH,math.huge,"dailycook1", "dough cooker")
addQuest("daily", "orangelingKilled", 15 , " orangelings defeated",REWARD_HIGH,math.huge,"dailycaptain2", "engine protector")
addQuest("daily", "bluelingKilled", 25 , " bluelings defeated",REWARD_HIGH,math.huge,"dailysecurity2", "blueling conquerer")
addQuest("daily", "weedKilled", 25 , " weeds killed",REWARD_HIGH,math.huge,"dailybotany2", "weed be gone")
addQuest("daily", "healthHealed", 3000 , " health healed",REWARD_HIGH,math.huge,"dailymedic2", "heal people 2")

addQuest("workers", "machinesFixed", 10 , " things fixed",REWARD_LOW,math.huge,"worker1", "machine fixing")
addQuest("scientists", "greenGooFilled", 5 , " goo filled",REWARD_LOW,math.huge,"science1", "container filler")
addQuest("cooks", "foodCooked", 15 , " foods cooked",REWARD_LOW,math.huge,"cook1", "chef souffle")
addQuest("captain", "machinesFixed", 15 , " machines fixed",REWARD_LOW,math.huge,"captain1", "captain fixer")
addQuest("security", "playersArrested", 3 , " players arrested",REWARD_LOW,math.huge,"security1", "peace keeping")
addQuest("botanists", "plantsWatered", 15 , " plants watered",REWARD_LOW,math.huge,"botany1", "waterer")
addQuest("medics", "healthHealed", 250 , " health healed",REWARD_LOW,math.huge,"medic1", "heal people")

addQuest("workers", "bluelingKilled", 10 , " bluelings defeated",REWARD_MED,math.huge,"worker2", "blueling conquerer")
addQuest("scientists", "weedTamed", 5 , " weeds tamed",REWARD_MED,math.huge,"science2", "weed friend maker")
addQuest("cooks", "doughCooked", 35 , " foods cooked",REWARD_MED,math.huge,"cook1", "dough cooker")
addQuest("captain", "orangelingKilled", 15 , " orangelings defeated",REWARD_MED,math.huge,"captain2", "engine protector")
addQuest("security", "bluelingKilled", 10 , " bluelings defeated",REWARD_MED,math.huge,"security2", "blueling conquerer")
addQuest("botanists", "weedKilled", 15 , " weeds killed",REWARD_MED,math.huge,"botany2", "weed be gone")
addQuest("medics", "healthHealed", 500 , " health healed",REWARD_MED,math.huge,"medic2", "heal people 2")

QuestData.randomQuestOfSubtype = function(subType, seed)
	local randomObject
	if seed then
		randomObject = Random.new(seed)
	else
		randomObject = Random.new()
	end
	local possibleQuests = QuestData.quests[subType]
	local index = randomObject:NextInteger(1, #possibleQuests)
	return possibleQuests[index].id
end

QuestData.lookupByID = function(id)
	--print("looking up by", id)
	for _, questType in pairs(QuestData.quests) do
		for _, quest in pairs(questType) do
			if quest.id == id then
				return quest
			end
		end
	end
end

return QuestData
