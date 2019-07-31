local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local PlayerData = import "Shared/PlayerData"

local CYCLE_TIME = 10

local thisCycle = {}

--[[
	thisCycle[player] = {
		["Machines Fixed"] = 5
		[""]
	}
]]

local defaultPaycheckInfo = function()
	return  {
		["No deaths"] = 10,
		["No station deaths"] = 45,
	}
end

local function addPaycheckStat(player, stat, value)
	local checkInfo = thisCycle[player]
	if not checkInfo[stat] then
		checkInfo[stat] = value
	else
		checkInfo[stat] = checkInfo[stat]
	end
end

local function awardAll(stat, value)
	for player, payData in pairs(thisCycle) do
		addPaycheckStat(player, stat, value)
	end
end

local function awardNobrokenMachines()
	if #CollectionService:GetTagged("Broken") == 0 then
		-- no broken machines!
		awardAll("No broken machines", 25)
	end
end

local function awardNoUntamedAliens()
	local untamed = false
	for _, alien in pairs(CollectionService:GetTagged("Animal")) do
		if alien.Parent == workspace then
			if not CollectionService:HasTag(alien, "Friendly") then
				untamed = true
			end
		end
	end
	if not untamed then
		awardAll("No untamed aliens", 25)
	end
end

local function awardLowAverageHunger()
	local totalHunger = 0
	local numPlayers = #game.Players:GetPlayers()
	for _, p in pairs(game.Players:GetPlayers()) do
		
	end
end

local function pay()
	awardNobrokenMachines()
	awardNoUntamedAliens()
	awardLowAverageHunger()
	for player, payData in pairs(thisCycle) do
		print("PLAYER", player)
		for i, v in pairs(payData) do print(i,v) end
		thisCycle[player] = defaultPaycheckInfo()
	end
end

local Paychecks = {}

function Paychecks:start()
	game.Players.PlayerAdded:connect(function(player)
		thisCycle[player] = defaultPaycheckInfo()
	end)
	Messages:hook("AddPaycheckStat", function(player, stat, value)
		addPaycheckStat(player,stat, value)
	end)
	Messages:hook("PlayerDied", function(player)
		awardAll("No station deaths", nil)
		thisCycle[player]["No deaths"] = nil
	end)
	spawn(function()
		while wait(CYCLE_TIME) do
			pay()
		end
	end)
end

return Paychecks
