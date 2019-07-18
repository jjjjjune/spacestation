local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Stats = {}

function Stats:start()
	Messages:hook("DamageMe", function(player,damage)
		player.Character.Humanoid:TakeDamage(damage)
	end)
end

return Stats
