local import = require(game.ReplicatedStorage.Shared.Import)

local Action = import "Action"

return Action(script.Name, function(layoutType)
	return {
		layoutType = layoutType
	}
end)