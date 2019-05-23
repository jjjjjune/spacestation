local import = require(game.ReplicatedStorage.Shared.Import)
local PlayerData = import "Shared/PlayerData"

return function(player)
	local mask = PlayerData:get(player, "idol")
	local modifier = 1
	if mask == "Mask Of Stone" then
		modifier = 2
	end
	if mask == "Mask Of Iron" then
		modifier = 4
	end
	return modifier
end
