local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local HasContraband = import "Shared/Utils/HasContraband"
local CollectionService = game:GetService("CollectionService")
local TeamData = import "Shared/Data/TeamData"

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
			if not CollectionService:HasTag(arrestTarget.Character, "Searched") then
				Messages:sendClient(player, "Notify", "This player needs to be searched at a checkpoint!")
				return
			end
			if HasContraband(arrestTarget) then
				arrestTarget.Character:SetPrimaryPartCFrame(jail.CFrame)
				removeContraband(arrestTarget)
			else
				Messages:sendClient(player, "Notify", "This player has done nothing wrong!")
			end
		elseif arrestTarget:IsA("Model") and arrestTarget:FindFirstChild("Humanoid") then
			-- nothing here for now
			arrestTarget:SetPrimaryPartCFrame(jail.CFrame)
		end
	end)
end

return Arrests
