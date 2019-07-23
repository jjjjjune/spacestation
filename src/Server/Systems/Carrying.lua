local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local Carrying = {}

function Carrying:start()
	Messages:hook("CarryObject", function(player, object)

	end)
	Messages:hook("ReleaseObject", function(player, object)

	end)
end

return Carrying
