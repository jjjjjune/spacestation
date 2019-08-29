local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TeamData = import "Shared/Data/TeamData"
local CollectionService = game:GetService("CollectionService")
local MarketplaceService = game:GetService("MarketplaceService")
local PlayerData = import "Shared/PlayerData"
local Teams = {}

local PAY_CYCLE_TIME = 300

local function countMembersOfTeam(teamName)
	local n = 0
	for _, v in pairs(game.Players:GetPlayers()) do
		if v.Team.Name == teamName then
			n = n + 1
		end
	end
	return n
end

local function switchTeam(player, teamName, bypassPass)
	local data = TeamData[teamName]
	local amount = countMembersOfTeam(teamName)
	if amount >= data.limit then
		return
	else
		if data.gamepass and not bypassPass then
			if not MarketplaceService:UserOwnsGamePassAsync(player.UserId, data.gamepass) then
				MarketplaceService:PromptGamePassPurchase(player, data.gamepass)
				return
			end
		end
		local prevTeam = player.Team.Name
		local prevTeamData = TeamData[prevTeam]
		for _, tool in pairs(prevTeamData.starterPack) do
			if player.Backpack:FindFirstChild(tool) then
				player.Backpack[tool]:Destroy()
			end
			if player.Character:FindFirstChild(tool) then
				player.Character[tool]:Destroy()
			end
		end
		player.Team = game.Teams[teamName]
		for _, tool in pairs(data.starterPack) do
			Messages:send("GiveTool", player, tool)
		end
		Messages:send("ApplyTeamAppearance",player,player.Character)
		Messages:send("OnTeamSwitched", player, teamName)
	end
end

local lastSound = time()

function Teams:start()
	Messages:hook("SwitchTeam", function(player, teamName)
		spawn(function() switchTeam(player, teamName) end)
	end)
	for _, switch in pairs(CollectionService:GetTagged("TeamSwitch")) do
		local hitbox = Instance.new("Part")
		hitbox.Size = switch:GetModelSize()*1.1
		hitbox.Anchored = true
		hitbox.Transparency = 1
		hitbox.CanCollide = false
		hitbox.CFrame = switch:GetModelCFrame()
		hitbox.Parent = switch
		local switchDetector = Instance.new("ClickDetector", hitbox)
		Messages:send("RegisterDetector", switchDetector, function(player)
			if not switch:FindFirstChild("Vote") then
				if time() - lastSound > 2 then
					lastSound = time()
					Messages:send("PlaySound", "Cop2", hitbox.Position)
				end
				Messages:sendClient(player, "OpenTeamSwitchGui", switch.Team.Value)
			else
				if time() - lastSound > 2 then
					lastSound = time()
					Messages:send("PlaySound", "Cop2", hitbox.Position)
				end
				Messages:sendClient(player, "OpenTeamSwitchVoteGui", switch.Team.Value)
			end
		end)
		for n = 1, 18 do
			if n ~= 16 then
				pcall(function () switch.Humanoid:SetStateEnabled(n, false) end)
			end
		end
		local anim = Instance.new("Animation", switch)
		anim.AnimationId = "http://www.roblox.com/asset/?id=616111295"
		local idleTrack = switch.Humanoid:LoadAnimation(anim)
		idleTrack:Play()
	end
	MarketplaceService.PromptGamePassPurchaseFinished:connect(function(player, gamepass, wasPurchased)
		if wasPurchased then
			for teamName, data in pairs(TeamData) do
				if data.gamepass and data.gamepass == gamepass then
					switchTeam(player, teamName, true)
				end
			end
		end
	end)
	game.Players.PlayerAdded:connect(function(player)
		player.CharacterAdded:connect(function(character)
			for _, toolName in pairs(TeamData[player.Team.Name].starterPack) do
				Messages:send("GiveTool", player, toolName)
			end
		end)
		Messages:send("OnTeamSwitched", player, "Workers")
	end)
	Messages:hook("FireFromJob",  function(player, playerToFire)
		if player.Team.Name == "Captain" then
			switchTeam(playerToFire, "Workers")
		end
	end)
end

return Teams
