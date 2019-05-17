local import = require(game.ReplicatedStorage.Shared.Import)

local Action = import "Action"

return Action(script.Name, function(userId, inventory)
	return {
		userId = userId,
		inventory = inventory,
	}
end)
