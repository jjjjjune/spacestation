local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'

local registeredDetectors = {}

local ClickDetectors = {}

function ClickDetectors:start()
	Messages:hook("RegisterDetector", function(detector, callback)
		registeredDetectors[detector] = callback
	end)
	Messages:hook("PlayerClicked", function(player, detector)
		if registeredDetectors[detector] then
			registeredDetectors[detector](player)
		end
	end)
end

return ClickDetectors
