local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local FoodData = import "Shared/Data/FoodData"

local Stats = {}

function Stats:start()
	Messages:hook("DamageMe", function(player,damage)
		player.Character.Humanoid:TakeDamage(damage)
	end)
	Messages:hook("Eat", function(player, food)

	end)
end

return Stats
