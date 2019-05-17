local import = require(game.ReplicatedStorage.Shared.Import)

local PlayerAdded = import "Shared/Actions/PlayerAdded"
local PlayerRemoving = import "Shared/Actions/PlayerRemoving"
local SetPlayerName = import "Shared/Actions/PlayerStats/SetPlayerName"
local Reducer = import("../../PlayerStats", { "reducer" })

return function()
	describe("player stats reduccer", function()
		local userId = "foo"

		it("should add state on PlayerAdded", function()
			local state = Reducer(nil, PlayerAdded(userId))
			expect(state[userId]).to.be.ok()
		end)

		it("should remove state on PlayerRemoving", function()
			local state = Reducer(nil, PlayerAdded(userId))
			state = Reducer(state, PlayerRemoving(userId))
			expect(state[userId]).to.never.be.ok()
		end)

		it("should be able to set a player's name", function()
			local state = Reducer(nil, PlayerAdded(userId))

			expect(state[userId].name).to.be.ok()

			state = Reducer(state, SetPlayerName(userId, "foo"))

			expect(state[userId].name).to.equal("foo")
		end)
	end)
end
