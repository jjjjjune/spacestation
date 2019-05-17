local import = require(game.ReplicatedStorage.Shared.Import)

local Action = import "Action"

return Action(script.Name, function(userId, position)
	return {
		userId = userId,
		position = position,
	}
end)
