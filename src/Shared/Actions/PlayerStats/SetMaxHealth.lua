local import = require(game.ReplicatedStorage.Shared.Import)

local Action = import "Action"

return Action(script.Name, function(userId,amount)
	return {
		maxHealth = amount,
		userId = userId,
	}
end)
