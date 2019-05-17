local import = require(game.ReplicatedStorage.Shared.Import)

local Messages = import "Shared/Utils/Messages"
local PlayerData = import "Shared/PlayerData"

local Death = {}

function Death:start()
	Messages:hook("PlayerDied", function(player)
		if player.Character:FindFirstChild("Head") then
			local position = player.Character.Head.Position
			Messages:send("PlayParticle", "Skulls", 20, position)
		end
		print("reset position")
		PlayerData:set(player, "position", nil)
		PlayerData:set(player, "lastHit", time() -1000)
		Messages:sendClient("Died", player)
	end)
	Messages:hook("PlayerReset", function(player)
		print("reset sacrifices")
		PlayerData:set(player, "sacrifices", {})
		Messages:send("RespawnPlayer", player)
	end)
end

return Death
