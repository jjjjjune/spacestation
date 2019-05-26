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
				local itemName = item.Name
				local itemPosition = item.Base.Position
				item:Destroy()
				Messages:send("MakeItem", "Cooked "..itemName, itemPosition)
				Messages:send("PlayParticle", "CookSmoke", 15, itemPosition)
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
	Grindstone = function(player, item)
		if CollectionService("HasTag", item, "Grindable") then
			Messages:send("MakeItem", string.gsub(item.Name, " Bar", "").." Blade", item.Base.Position)
			Messages:send("PlayParticle", "CookSmoke", 15, item.Base.Position)
			Messages:send("PlaySound", "GoodCraft", item.Base.Position)
			item:Destroy()
		end
	end,
	["Compost Bin"] = function(player, item, building)
		local data = ItemData[item.Name]
		if data and data.consumable then
			--if CollectionService("HasTag", item, "Compostable") then
			local progress = building.Progress
			if progress.Value == progress.MaxValue then
				progress.Value = 1
				Messages:send("MakeItem", "Compost", item.Base.Position)
			else
				progress.Value = progress.Value + 1
			end
			building.compost.Transparency = (1 ) - (progress.Value/progress.MaxValue)

			Messages:send("PlayParticle", "CookSmoke", 15, item.Base.Position)
			--Messages:send("PlaySound", "GoodCraft", item.Base.Position)
			item:Destroy()
			--end
		end
	end,
}
