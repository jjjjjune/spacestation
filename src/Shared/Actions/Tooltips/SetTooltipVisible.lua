local import = require(game.ReplicatedStorage.Shared.Import)

local action = import "Action"

return action(script.Name, function(visible)
	return {
		visible = visible
	}
end)
