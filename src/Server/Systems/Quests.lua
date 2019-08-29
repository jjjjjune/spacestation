local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local PlayerData = import "Shared/PlayerData"
local QuestData = import "Shared/Data/QuestData"
local AddCash = import "Shared/Utils/AddCash"

local function startNewQuest(player, questID)
	local quests = PlayerData:get(player, "quests")
	local questData = QuestData.lookupByID(questID)
	local stat = PlayerData:get(player, questData.stat) or 0
	quests[questID] = {
		stat = questData.stat,
		startAmount = stat,
		endAmount = stat + questData.amount,
		timeEnd = tick() + questData.length,
		start = tick(),
		isTeam = questData.isTeam,
		team = (questData.isTeam and questData.subType) or nil
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
		local myStat = PlayerData:get(player, quest.stat) or 0
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

local function onPlayerAdded(player)
	-- check if player doesnt have a daily quest, and also that it has been more than a DAY since last one
	--Messages:send("StartQuest", player, "dailytest1")
	--Messages:send("StartQuest", player, "dailytest2")
	local quests = PlayerData:get(player, "quests")
	local hasDaily = false
	for _, quest in pairs(quests) do
		if quest.subType == "daily" then
			hasDaily = true
		end
	end
	if not hasDaily then
		local lastDaily = PlayerData:get(player, "lastDaily")
		if (not lastDaily) or ((tick() - lastDaily) > QuestData.DAY) then
			local dailyQuestID = QuestData.randomQuestOfSubtype("daily")
			Messages:send("StartQuest", player, dailyQuestID)
			PlayerData:set(player, "lastDaily", tick())
		end
	end
end

local function onPlayerTeamSwitched(player, team)
	-- give the player a team based quest if they don't have one already
	local needsTeamQuest = true
	local quests = PlayerData:get(player, "quests")
	for _, quest in pairs(quests) do
		if quest.subType == string.lower(team) then
			needsTeamQuest = false
		end
	end
	if needsTeamQuest then
		local questID = QuestData.randomQuestOfSubtype(string.lower(team))
		Messages:send("StartQuest", player, questID)
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
	Messages:hook("OnTeamSwitched", function(player, team)
		onPlayerTeamSwitched(player, team)
	end)
	game:GetService("RunService").Stepped:connect(function()
		onStep()
	end)
	game.Players.PlayerAdded:connect(function(player)
		onPlayerAdded(player)
	end)
end

return Quests
