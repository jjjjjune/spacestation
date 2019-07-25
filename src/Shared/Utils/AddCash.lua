local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local PlayerData = import "Shared/PlayerData"

return function(player, cash)
	PlayerData:add(player, "cash", cash)
	Messages:sendClient(player, "Notify", "+ $"..cash.."")
end

