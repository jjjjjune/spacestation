local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TeamData = import "Shared/Data/TeamData"

local playerLives = {}

local Lives = {}

function Lives:start()
	Messages:hook("OnTeamSwitched", function(player, teamName)
		local data = TeamData[teamName]
		if data.lives then
			playerLives[player] = data.lives
		else
			playerLives[player] = nil
		end
		Messages:sendClient(player, "NotifyLivesLeft", playerLives[player])
	end)
	Messages:hook("PlayerDied", function(player)
		if playerLives[player] then
			playerLives[player] = playerLives[player] - 1
			if playerLives[player] <= 0 then
				Messages:send("SwitchTeam", player, "Workers")
			end
		end
	end)
	Messages:hook("CharacterAdded", function(player, character)
		Messages:sendClient(player, "NotifyLivesLeft", playerLives[player])
	end)
end

return Lives
