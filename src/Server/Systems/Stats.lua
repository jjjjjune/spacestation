local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local FoodData = import "Shared/Data/FoodData"
local PlayerData = import "Shared/PlayerData"

local Stats = {}

function Stats:start()
	Messages:hook("DamageMe", function(player,damage)
		player.Character.Humanoid:TakeDamage(damage)
	end)
	Messages:hook("Eat", function(player, food)
		Messages:send("PlaySound", "Eating", food.PrimaryPart.Position)
		print(food.Name)
		FoodData[food.Name](player.Character, food)
		food:Destroy()
	end)
	Messages:hook("SetHunger", function(player, hunger)
		PlayerData:set(player, "hunger", hunger)
	end)
end

return Stats


