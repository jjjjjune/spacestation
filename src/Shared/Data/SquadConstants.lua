local import = require(game.ReplicatedStorage.Shared.Import)

local t = import "t"

return {
	-- The max number of users in the squad
	MAX_USERS = 4,

	ISquad = t.interface({
		id = t.string,
		users = t.array(t.string)
	})
}
