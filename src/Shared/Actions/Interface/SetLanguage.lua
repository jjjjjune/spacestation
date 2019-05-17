local import = require(game.ReplicatedStorage.Shared.Import)

local Action = import "Action"

return Action(script.Name, function(language)
	return {
		language = language
	}
end)