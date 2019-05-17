local import = require(game.ReplicatedStorage.Shared.Import)

local Action = import "Action"

return Action(script.Name, function(userId, item,position)
	return {
		userId = userId,
		position = position,
		item = item,
	}
end)
