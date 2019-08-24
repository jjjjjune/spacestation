local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local HasContraband = import "Shared/Utils/HasContraband"
local CollectionService = game:GetService("CollectionService")
local TeamData = import "Shared/Data/TeamData"
local AddCash = import "Shared/Utils/AddCash"

local ARREST_TIME = 120
local lastArrests = {}

local function removeContraband(player)
	local playerAccessTable = TeamData[player.Team.Name].access
	for _, tool in pairs(player.Backpack:GetChildren()) do
		if tool:FindFirstChild("Access") then
			local canAccess = false
			for _, accessType in pairs(playerAccessTable) do
				if accessType == tool.Access.Value then
					canAccess = true
				end
			end
			if not canAccess then
				tool:Destroy()
			end
		end
	end
end

local function arrest(player, arrestTarget)
	spawn(function()
		arrestTarget.Character.Humanoid.Jump = true
		wait()
		lastArrests[arrestTarget] =time()
		local jail = CollectionService:GetTagged("Jail")[1]
		arrestTarget.Character:SetPrimaryPartCFrame(jail.CFrame)
		removeContraband(arrestTarget)
		Messages:sendClient(player, "Notify", "Arrested this player!")
		AddCash(player, 5)
		Messages:sendClient(arrestTarget, "Notify", "You have been arrested for "..ARREST_TIME.." seconds!")
	end)
end

local Arrests = {}

function Arrests:start()
	local jail = CollectionService:GetTagged("Jail")[1]
	jail.Transparency = 1
	Messages:hook("AttemptArrest", function(player, arrestTarget)
		if arrestTarget:IsA("Player") then
			if CollectionService:HasTag(arrestTarget.Character, "Alien") then
				arrestTarget.Character:SetPrimaryPartCFrame(jail.CFrame)
				removeContraband(arrestTarget)
				return
			end
			--[[if not CollectionService:HasTag(arrestTarget.Character, "Searched") then
				Messages:sendClient(player, "Notify", "This player needs to be searched at a checkpoint!")
				return
			end--]]
			if HasContraband(arrestTarget) or game:GetService("RunService"):IsStudio() then
				arrest(player, arrestTarget)
			else
				Messages:sendClient(player, "Notify", "This player has done nothing wrong!")
			end
		elseif arrestTarget:IsA("Model") and arrestTarget:FindFirstChild("Humanoid") then
			Messages:sendClient(player, "Notify", "Sent to the science lab!")
			local scienceArea = CollectionService:GetTagged("ScienceArea")[1]
			arrestTarget:SetPrimaryPartCFrame(scienceArea.CFrame)
		end
	end)
	Messages:hook("CharacterAdded", function(player, character)
		if lastArrests[player] then
			if time() - lastArrests[player] < ARREST_TIME then
				spawn(function()
					wait()
					character:SetPrimaryPartCFrame(jail.CFrame)
					local secondsRemaining= ARREST_TIME - (time() - lastArrests[player])
					Messages:sendClient(player, "Notify", "In jail for another "..math.floor(secondsRemaining).." seconds!")
				end)
			end
		end
	end)
end

return Arrests
