local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'

local kicked = {}

local Kicks = {}
function Kicks:start()
	Messages:hook("KickPlayer", function(player)
		kicked[player.Name] = true
		player:Kick("You have been votekicked from the server. Please behave yourself.")
	end)
	game.Players.PlayerAdded:connect(function(player)
		if kicked[player.Name] then
			player:Kick("You cannot rejoin kicked servers.")
		end
	end)
end
return Kicks
