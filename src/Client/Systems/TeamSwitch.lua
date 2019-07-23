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
		print("opening")
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
end

return TeamSwitch
