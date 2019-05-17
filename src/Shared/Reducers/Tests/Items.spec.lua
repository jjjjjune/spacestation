local import = require(game.ReplicatedStorage.Shared.Import)

local AddItem = import "Shared/Actions/Items/AddItem"
local RemoveItem = import "Shared/Actions/Items/RemoveItem"
local ChangeItemProperty = import "Shared/Actions/Items/ChangeItemProperty"
local Reducer = import("../../Items", { "reducer" })

return function()
	local itemId = "itemId"
	local userId = "userId"
	local staticId = "staticId"

	describe("items Reducer", function()
		it("should handle adding an item", function()
			local state = Reducer(nil, AddItem(itemId, staticId, userId))
			expect(state[itemId]).to.be.ok()
		end)

		it("should handle removing an item", function()
			local state = Reducer(nil, AddItem(itemId, staticId, userId))
			state = Reducer(state, RemoveItem(itemId))
			expect(state[itemId]).to.never.be.ok()
		end)

		it("should handle changing an item's properties", function()
			local state = Reducer(nil, AddItem(itemId, staticId, userId))
			state = Reducer(state, ChangeItemProperty(itemId, "ownerId", "foo"))
			expect(state[itemId].ownerId).to.equal("foo")
		end)
	end)
end
