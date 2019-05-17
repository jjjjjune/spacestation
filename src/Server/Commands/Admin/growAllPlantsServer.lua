return function (_, n)
	local import = require(game.ReplicatedStorage.Shared.Import)
	local Messages = import "Shared/Utils/Messages"
	Messages:send("GrowAllPlants",n)
	return "done"
end
