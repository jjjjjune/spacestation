local import = require(game.ReplicatedStorage.Shared.Import)

local action = import "Action"

return action(script.Name, function(position)
	return {
		position = position
	}
end)
