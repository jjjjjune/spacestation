local import = require(game.ReplicatedStorage.Shared.Import)
local PlayerData = import "Shared/PlayerData"

return function (_, player, stat, value)
	PlayerData:set(player, stat, value)
	return "cool"
end
