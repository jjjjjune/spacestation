local import = require(game.ReplicatedStorage.Shared.Import)

local Immutable = import "Immutable"
local t = import "t"
local CreateReducer = import("Rodux", { "createReducer" })
local Functional = import "Shared/Utils/Functional"
local SquadConstants = import "Shared/Data/SquadConstants"
local CreateSquad = import "Shared/Actions/Squads/CreateSquad"
local DisbandSquad = import "Shared/Actions/Squads/DisbandSquad"
local AddPlayerToSquad = import "Shared/Actions/Squads/AddPlayerToSquad"
local RemovePlayerFromSquad = import "Shared/Actions/Squads/RemovePlayerFromSquad"

local exports = {}

local getSquadForOwnerCheck = t.tuple(t.table, t.string)
function exports.getSquadForOwner(state, ownerId)
	assert(getSquadForOwnerCheck(state, ownerId))

	for _, squad in pairs(state.squads) do
		-- Right now the owner is just assumed to be the first user in the list
		-- of users. In the future it might be better to have an `ownerId` field
		-- on each squad.
		if squad.users[1] == ownerId then
			return squad
		end
	end
end

exports.reducer = CreateReducer({}, {
	[CreateSquad.name] = function(state, action)
		return Immutable.join(state, {
			[action.id] = {
				id = action.id,
				users = action.userIds
			}
		})
	end,

	[DisbandSquad.name] = function(state, action)
		state = Immutable.copy(state)
		state[action.id] = nil
		return state
	end,

	[AddPlayerToSquad.name] = function(state, action)
		local squad = state[action.id]

		-- this might be better as a thunk?
		if squad and #squad.users < SquadConstants.MAX_USERS then
			if not Functional.find(squad.users, action.userId) then
				return Immutable.join(state, {
					[action.id] = Immutable.join(squad, {
						users = Immutable.append(squad.users, action.userId)
					})
				})
			end
		end

		return state
	end,

	[RemovePlayerFromSquad.name] = function(state, action)
		local squad = state[action.id]

		if squad then
			return Immutable.join(state, {
				[action.id] = Immutable.join(squad, {
					users = Functional.filter(squad.users, function(userId)
						return userId ~= action.userId
					end)
				})
			})
		end

		return state
	end
})

return exports
