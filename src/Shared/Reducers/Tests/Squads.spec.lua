local import = require(game.ReplicatedStorage.Shared.Import)

local SquadConstants = import "Shared/Data/SquadConstants"
local CreateSquad = import "Shared/Actions/Squads/CreateSquad"
local DisbandSquad = import "Shared/Actions/Squads/DisbandSquad"
local AddPlayerToSquad = import "Shared/Actions/Squads/AddPlayerToSquad"
local RemovePlayerFromSquad = import "Shared/Actions/Squads/RemovePlayerFromSquad"
local Reducer = import("../../Squads", { "reducer" })

return function()
	describe("squad reducer", function()
		local squadId = "foo"

		describe("CREATE", function()
			it("should handle creating a squad with just the host", function()
				local state = Reducer(nil, CreateSquad(squadId, { "userId" }))

				expect(state[squadId]).to.be.ok()
			end)

			it("should handle creating a squad with multiple users", function()
				local users = { "user1", "user2", "user3" }
				local state = Reducer(nil, CreateSquad(squadId, users))

				expect(#state[squadId].users).to.equal(3)
			end)

			it("should error when trying to create a squad with too many users", function()
				local users = {}
				for _=1, SquadConstants.MAX_USERS+1 do
					table.insert(users, "foo")
				end

				expect(function()
					Reducer(nil, CreateSquad(squadId, users))
				end).to.throw()
			end)

			it("should handle creating multiple squads", function()
				local state
				for i=1, 3 do
					state = Reducer(state, CreateSquad(("squad%i"):format(i), { "user1" }))
				end

				expect(state["squad1"]).to.be.ok()
				expect(state["squad2"]).to.be.ok()
				expect(state["squad3"]).to.be.ok()
			end)
		end)

		it("should handle DISBAND", function()
			local state = Reducer(nil, CreateSquad(squadId, { "user1" }))

			state = Reducer(state, DisbandSquad(squadId))

			expect(state[squadId]).to.never.be.ok()
		end)

		describe("INVITE_PLAYER", function()
			it("should add a player to the list of users", function()
				local state = Reducer(nil, CreateSquad(squadId, { "user1" }))

				state = Reducer(state, AddPlayerToSquad(squadId, "user2"))

				expect(#state[squadId].users).to.equal(2)
			end)

			it("should not allow the same user to be added more than once", function()
				local state = Reducer(nil, CreateSquad(squadId, { "user1" }))

				state = Reducer(state, AddPlayerToSquad(squadId, "user1"))

				expect(#state[squadId].users).to.equal(1)
			end)

			it("should not exceed the max number of players", function()
				local users = {}
				for _=1, SquadConstants.MAX_USERS do
					table.insert(users, "foo")
				end

				local state  = Reducer(nil, CreateSquad(squadId, users))

				expect(#state[squadId].users).to.equal(SquadConstants.MAX_USERS)

				state = Reducer(state, AddPlayerToSquad(squadId, "foo"))

				expect(#state[squadId].users).to.equal(SquadConstants.MAX_USERS)
			end)
		end)

		describe("REMOVE_PLAYER", function()
			it("should remove a player from the list of users", function()
				local state = Reducer(nil, CreateSquad(squadId, { "user1", "user2" }))

				expect(#state[squadId].users).to.equal(2)

				state = Reducer(state, RemovePlayerFromSquad(squadId, "user2"))

				expect(#state[squadId].users).to.equal(1)
			end)

			it("should fail silently when trying to remove someone not in the squad", function()
				local state = Reducer(nil, CreateSquad(squadId, { "user1" }))

				expect(function()
					Reducer(state, RemovePlayerFromSquad(squadId, "user2"))
				end).to.never.throw()
			end)
		end)
	end)
end
