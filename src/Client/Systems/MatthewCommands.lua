local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"

local MatthewCommands = {}

function MatthewCommands:start()
	local Cmdr = require(game.ReplicatedStorage:WaitForChild("CmdrClient"))
	-- Configurable, and you can choose multiple keys
	Cmdr:SetActivationKeys({ Enum.KeyCode.Semicolon })
	local player = game.Players.LocalPlayer
	player:GetMouse().KeyDown:connect(function(key)
		if key == "m" then
			if game:GetService("RunService"):IsStudio() or player.Name == "Wheatlies" then
				player.Character:MoveTo(player:GetMouse().Hit.p)
			end
		end
	end)
end

return MatthewCommands
