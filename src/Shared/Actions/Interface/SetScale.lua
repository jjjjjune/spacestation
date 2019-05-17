local import = require(game.ReplicatedStorage.Shared.Import)

local Action = import "Action"
local t = import "t"

local argumentCheck = t.tuple(t.number)
return Action(script.Name, function(scale)
	assert(argumentCheck(scale))
	return {
		scale = scale
	}
end)

