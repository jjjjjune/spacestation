local import = require(game.ReplicatedStorage.Shared.Import)
local Store = import "Shared/State/Store"
local Backpacks = import "Shared/Data/Backpacks"

return function(player)
	local state= Store:getState()
	local inventory = state.inventories[tostring(player.UserId)]
	local baseSize = 16
	for _, itemName in pairs(inventory) do
		if Backpacks[itemName] then
			baseSize = baseSize + Backpacks[itemName]
		end
	end
	return math.min(32, baseSize)
end
