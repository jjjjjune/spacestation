local import = require(game.ReplicatedStorage.Shared.Import)

local Action = import "Action"
local t = import "t"

local check = t.tuple(t.string, t.string)

return Action(script.Name, function(userId, name)
	assert(check(userId, name))

	return {
		userId = userId,
		name = name
	}
end)
