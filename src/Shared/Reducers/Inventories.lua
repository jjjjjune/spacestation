local import = require(game.ReplicatedStorage.Shared.Import)

local CreateReducer = import("Rodux", { "createReducer" })
local Immutable = import "Immutable"
local RemoveByKey = import "../Generic/RemoveByKey"

local exports = {}

exports.reducer = CreateReducer({}, {
	PlayerAdded = function(state, action)
		return Immutable.join(state, {
			[action.userId] = {

			}
		})
	end,

	SetInventory = function(state, action)
		return Immutable.set(state,action.userId,action.inventory)
	end,

	SetItemPosition = function(state, action)
		return Immutable.join(state, {
			[action.userId] = Immutable.set(state[action.userId], action.position, action.item)
		})
	end,

	RemoveItem = function(state, action)
		return Immutable.join(state, {
			[action.userId] = {
				[action.position] = nil
			}
		})
	end,

	PlayerRemoving = RemoveByKey("userId"),
})

return exports
