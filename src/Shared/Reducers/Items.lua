local import = require(game.ReplicatedStorage.Shared.Import)

local CreateReducer = import("Rodux", { "createReducer" })
local Immutable = import "Immutable"
local AddItem = import "Shared/Actions/Items/AddItem"
local RemoveItem = import "Shared/Actions/Items/RemoveItem"
local ChangeItemProperty = import "Shared/Actions/Items/ChangeItemProperty"
local RemoveByKey = import "../Generic/RemoveByKey"

local exports = {}

exports.reducer = CreateReducer({}, {
	[AddItem.name] = function(state, action)
		return Immutable.join(state, {
			[action.itemId] = {
				id = action.itemId,
				staticId = action.staticId,
				ownerId = action.ownerId
			}
		})
	end,

	[RemoveItem.name] = RemoveByKey("itemId"),

	[ChangeItemProperty.name] = function(state, action)
		local item = state[action.itemId]

		return Immutable.join(state, {
			[action.itemId] = Immutable.join(item, {
				[action.key] = action.value
			})
		})
	end
})

return exports
