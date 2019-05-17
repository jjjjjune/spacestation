local import = require(game.ReplicatedStorage.Shared.Import)
local Store = import "Shared/State/Store"
local PlayerAdded = import "Shared/Actions/PlayerAdded"

local ClientInitStuff = {}

function ClientInitStuff:start()
	local id = tostring(game.Players.LocalPlayer.UserId)
	Store:dispatch(PlayerAdded(id))
end

return ClientInitStuff
