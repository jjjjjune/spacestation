local import = require(game.ReplicatedStorage.Shared.Import)
local ItemData = import "Shared/Data/ItemData"
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local BURN_CHANCE = 3

return {
	Campfire = function(player, item)
		local data = ItemData[item.Name]
		if data and data.consumable then
			if not string.find(item.Name, "Cooked") then
				Messages:send("MakeItem", "Cooked "..item.Name, item.Base.Position)
				Messages:send("PlayParticle", "CookSmoke", 15, item.Base.Position)
				item:Destroy()
				--if math.random(1, 10) < BURN_CHANCE t
			end
		end
	end,
	Furnace = function(player, item)
		if CollectionService("HasTag", item, "Ore") then
			Messages:send("MakeItem", item.Name.." Bar", item.Base.Position)
			Messages:send("PlayParticle", "CookSmoke", 15, item.Base.Position)
			Messages:send("PlaySound", "GoodCraft", item.Base.Position)
			item:Destroy()
		end
	end,
}
