local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TeamData = import "Shared/Data/TeamData"

local function countMembersOfTeam(teamName)
	local n = 0
	for _, v in pairs(game.Players:GetPlayers()) do
		if v.Team.Name == teamName then
			n = n + 1
		end
	end
	return n
end

local TeamSwitch = {}

function TeamSwitch:start()
	Messages:hook("OpenTeamSwitchGui", function(teamName)
		local data = TeamData[teamName]
		local number = countMembersOfTeam(teamName)
		local max = data.limit
		local amountString = "("..number.."/"..max..")"
		if max > 100 then
			amountString = ""
		end
		Messages:send("OpenYesNoDialogue", {
			text = "JOIN: "..teamName.. amountString,
			yesCallback = function()
				Messages:sendServer("SwitchTeam", teamName)
			end,
		})
	end)
	Messages:hook("OpenTeamSwitchVoteGui", function(teamName)
		Messages:send("OpenYesNoDialogue", {
			text = "RUN FOR: "..teamName.." (requires vote)",
			yesCallback = function()
				Messages:sendServer("StartVote", teamName)
			end,
		})
	end)
	Messages:hook("MakeVoteNotification", function(player, teamName, VOTE_TIME)
		local voteText = player.Name.." is running for: "..teamName.."!"..[[
			Type !yes or !no in the chat to vote! Vote lasts ]]..VOTE_TIME.." seconds!"
		game.StarterGui:SetCore("ChatMakeSystemMessage",{
			Text = voteText,
			Color = Color3.new(1,1,1),
			Font = Enum.Font.SourceSansBold,
			TextSize = 24
		})
	end)
	Messages:hook("MakeVoteSucceededNotification", function(running, team, yesVotes, noVotes)
		local yesPercent = math.ceil(yesVotes/(#game.Players:GetPlayers()))*100
		local noPercent = math.ceil(noVotes/(#game.Players:GetPlayers()))*100
		local voteData = "\n ("..yesPercent.."% YES) ("..noPercent.."% NO)"
		local voteText = running.Name.." has been elected "..team.."!"..voteData
		game.StarterGui:SetCore("ChatMakeSystemMessage",{
			Text = voteText,
			Color = Color3.new(.7,1,.7),
			Font = Enum.Font.SourceSansBold,
			TextSize = 24
		})
	end)
	Messages:hook("MakeVoteFailedNotification", function(running, team, yesVotes, noVotes)
		local yesPercent = math.ceil(yesVotes/(#game.Players:GetPlayers()))*100
		local noPercent = math.ceil(noVotes/(#game.Players:GetPlayers()))*100
		local voteData = "\n ("..yesPercent.."% YES) ("..noPercent.."% NO)"
		local voteText = running.Name.." has NOT been elected "..team.."!"..voteData
		game.StarterGui:SetCore("ChatMakeSystemMessage",{
			Text = voteText,
			Color = Color3.new(1,.7,.7),
			Font = Enum.Font.SourceSansBold,
			TextSize = 24
		})
	end)
end

return TeamSwitch
