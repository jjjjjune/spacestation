local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local PlayerData = import "Shared/PlayerData"

local Death = {}

function Death:start()
	Messages:hook("PlayerDied", function(player)
		if player.Character and player.Character:FindFirstChild("Head") then
			local position = player.Character.Head.Position
			Messages:send("PlayParticle", "Skulls", 20, position)
		end
		PlayerData:set(player, "position", nil)
		PlayerData:set(player, "lastHit",  -1000000)
		Messages:sendClient("Died", player)
	end)
	Messages:hook("PlayerReset", function(player)
		PlayerData:set(player, "sacrifices", {})
		PlayerData:set(player, "position", nil)
		PlayerData:set(player, "lastHit",  -1000000)
		Messages:send("RespawnPlayer", player)
	end)
end

return Death
