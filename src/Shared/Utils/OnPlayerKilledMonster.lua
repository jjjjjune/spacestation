local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local PlayerData = import "Shared/PlayerData"

return function (murdererPlayer, victim)
	PlayerData:add(murdererPlayer, victim.Name:lower().."Killed",1)
end
