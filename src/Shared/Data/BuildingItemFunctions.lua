local import = require(game.ReplicatedStorage.Shared.Import)
local ItemData = import "Shared/Data/ItemData"
local Messages = import "Shared/Utils/Messages"

local BURN_CHANCE = 3

return {
	Campfire = function(player, item)
		local data = ItemData[item.Name]
		if data and data.consumable then
			if not string.find(item.Name, "Cooked") then
				local cookedItem = game.ReplicatedStorage.Assets.Items["Cooked "..item.Name]:Clone()
				cookedItem.Parent = workspace
				cookedItem.PrimaryPart = cookedItem.Base
				cookedItem:SetPrimaryPartCFrame(item.Base.CFrame)
				Messages:send("PlayParticle", "CookSmoke", 15, cookedItem.Base.Position)
				item:Destroy()
				--if math.random(1, 10) < BURN_CHANCE t
			end
		end
	end
}
