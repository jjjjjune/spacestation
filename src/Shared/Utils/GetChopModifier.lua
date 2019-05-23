local import = require(game.ReplicatedStorage.Shared.Import)
local PlayerData = import "Shared/PlayerData"

return function(player)
	local mask = PlayerData:get(player, "idol")
	local modifier = 1
	return modifier
end
