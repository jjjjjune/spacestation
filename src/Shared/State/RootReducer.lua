--[[
	Root reducer for the game state.

	Add your reducers here to hook them up with the store.
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local CombineReducers = import("Rodux", { "combineReducers" })

local rootReducer = CombineReducers({
	playerStats = import("Shared/Reducers/PlayerStats", { "reducer" }),
	inventories = import("Shared/Reducers/Inventories", { "reducer" }),
	tooltipInfo = import("Shared/Reducers/TooltipInfo", { "reducer" })
})

return rootReducer
