local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local PlayerData = import "Shared/PlayerData"
local QuestData = import "Shared/Data/QuestData"
local AddCash = import "Shared/Utils/AddCash"

local function startNewQuest(player, questID)
	local quests = PlayerData:get(player, "quests")
	local questData = QuestData.lookupByID(questID)
	local stat = PlayerData:get(player, questData.stat)
	quests[questID] = {
		stat = questData.stat,
		startAmount = stat,
		endAmount = stat + questData.amount,
		timeEnd = tick() + questData.length,
		start = tick(),
	}
	PlayerData:set(player, "quests", quests)
end

local function onFinishedQuest(player, questID)
	local quests = PlayerData:get(player, "quests")
	quests[questID] = nil
	PlayerData:set(player, "quests", quests)
	local data = QuestData.lookupByID(questID)
	local reward = data.reward
	AddCash(player, reward.cash)
	local rewardString = " + $"..reward.cash
	Messages:sendClient(player, "Notify", "Quest complete! "..rewardString)
end

local function onPlayerDataUpdated(player)
	local data = PlayerData:get(player, "quests")
	for questID, quest in pairs(data) do
		local myStat = PlayerData:get(player, quest.stat)
		if myStat >= quest.endAmount then
			onFinishedQuest(player, questID)
			data[questID] = nil
			return
		else
			--print("needs: ", quest.endAmount - myStat)
		end
	end
end

local function onStep()
	for _, player in pairs(game.Players:GetPlayers()) do
		local quests = PlayerData:get(player, "quests")
		local shouldUpdate = false
		for questID, quest in pairs(quests) do
			if tick() > quest.timeEnd then
				shouldUpdate = true
				quests[questID] = nil
			end
		end
		if shouldUpdate then
			PlayerData:set(player, "quests", quests)
		end
	end
end

local Quests = {}

function Quests:start()
    Messages:hook("StartQuest", function(player, questID)
		local quests=  PlayerData:get(player, "quests")
		if quests[questID] then
		else
			startNewQuest(player, questID)
		end
	end)
	Messages:hook("PlayerDataUpdated", function(player)
		onPlayerDataUpdated(player)
	end)
	game:GetService("RunService").Stepped:connect(function()
		onStep()
	end)
	game.Players.PlayerAdded:connect(function(player)
		Messages:send("StartQuest", player, "dailytest1")
		Messages:send("StartQuest", player, "dailytest2")
	end)
end

return Quests
