local import = require(game.ReplicatedStorage.Shared.Import)
local PlayerData = import "Shared/PlayerData"

return function(player)
	local mask = PlayerData:get(player, "idol")
	local modifier = 1
	if mask == "Mask Of Brutality" then
		modifier = .7
	end
	return modifier
end
