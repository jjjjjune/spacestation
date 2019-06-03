-- TODO add global PLAYER_ADDED and PLAYER_REMOVING events

local import = require(game.ReplicatedStorage.Shared.Import)

local Immutable = import "Immutable"
local t = import "t"
local CreateReducer = import("Rodux", { "createReducer" })
local RemoveByKey = import "../Generic/RemoveByKey"

local exports = {}

exports.IPlayerStats = t.interface({
	name = t.string,
	health = t.integer
})

exports.IPlayerStatsState = t.map(t.string, exports.IPlayerStats)

exports.reducer = CreateReducer({}, {
	PlayerAdded = function(state, action)
		return Immutable.join(state, {
			[action.userId] = {
				hunger = 100,
				thirst = 100,
				maxHealth =100,
				health = 100,
				timeAlive = 0,
			}
		})
	end,

	PlayerRemoving = RemoveByKey("userId"),
	SetTimeAlive= function(state, action)
		return Immutable.join(state, {
			[action.userId] = Immutable.join(state[action.userId], {
				timeAlive = action.timeAlive,
			})
		})
	end,
	SetHealth = function(state, action)
		return Immutable.join(state, {
			[action.userId] = Immutable.join(state[action.userId], {
				health = action.health,
			})
		})
	end,
	SetMaxHealth = function(state, action)
		
		return Immutable.join(state, {
			[action.userId] = Immutable.join(state[action.userId], {
				maxHealth = action.maxHealth,
			})
		})
	end,
	SetThirst = function(state, action)
		return Immutable.join(state, {
			[action.userId] = Immutable.join(state[action.userId], {
				thirst = action.thirst,
			})
		})
	end,
	SetHunger= function(state, action)
		return Immutable.join(state, {
			[action.userId] = Immutable.join(state[action.userId], {
				hunger = action.hunger,
			})
		})
	end,
})

return exports
