local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local TAME_CHANCE = 10 -- out of 100

return function(player, monster)
	if math.random(1, 100) <= TAME_CHANCE then
		Messages:send("OnSucessfulTame", player, monster)
	else
		Messages:send("OnFailedTame", player, monster)
	end
end
