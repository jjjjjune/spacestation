local import = require(game.ReplicatedStorage.Shared.Import)

local PlayerAdded = import "Shared/Actions/PlayerAdded"
local PlayerRemoving = import "Shared/Actions/PlayerRemoving"
local AddItemToInventory = import "Shared/Actions/Inventories/AddItemToInventory"
local RemoveItemFromInventory = import "Shared/Actions/Inventories/RemoveItemFromInventory"
local Reducer = import("../../Inventories", { "reducer" })

return function()
	local userId = "userId"
	local itemId = "itemId"

	describe("inventories reducer", function()
		it("should handle adding an inventory", function()
			local state = Reducer(nil, PlayerAdded(userId))
			expect(state[userId]).to.be.ok()
		end)

		it("should handle removing an inventory", function()
			local state = Reducer(nil, PlayerAdded(userId))
			state = Reducer(state, PlayerRemoving(userId))
			expect(state[userId]).to.never.be.ok()
		end)

		describe("adding an item", function()
			it("should handle adding an item to an inventory", function()
				local state = Reducer(nil, PlayerAdded(userId))
				state = Reducer(state, AddItemToInventory(userId, itemId))
				expect(#state[userId].items).to.equal(1)
			end)

			it("should error when the inventory doesn't exist", function()
				expect(function()
					Reducer(nil, AddItemToInventory(itemId))
				end).to.throw()
			end)
		end)

		describe("removing an item", function()
			it("should handle removing an item from an inventory", function()
				local state = Reducer(nil, PlayerAdded(userId))
				state = Reducer(state, AddItemToInventory(userId, itemId))
				state = Reducer(state, RemoveItemFromInventory(userId, itemId))
				expect(#state[userId].items).to.equal(0)
			end)

			it("should error when the inventory doesn't exist", function()
				expect(function()
					Reducer(nil, RemoveItemFromInventory(userId, itemId))
				end).to.throw()
			end)
		end)
	end)
end
