local QuestData = {}

QuestData.DAY = 16*60*60
QuestData.quests = {}

QuestData.quests.daily = {}
QuestData.quests.workers = {}
QuestData.quests.scientists = {}
QuestData.quests.cooks = {}
QuestData.quests.captain = {}
QuestData.quests.security = {}
QuestData.quests.botanists = {}

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
	})
end

local genericCashReward = {
	cash = 10,
}

addQuest("daily", "machinesFixed", 2 ," machines fixed",genericCashReward,QuestData.DAY,"dailytest1", "fix 1 machines")
addQuest("daily", "machinesFixed", 3 , " machines fixed",genericCashReward,1000,"dailytest2", "fix 3 machines")

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
