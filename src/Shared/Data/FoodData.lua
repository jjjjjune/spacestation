local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local function genericEat(character, item)
	local player = game.Players:GetPlayerFromCharacter(character)
	if player then
		Messages:sendClient(player, "AddHunger", item.Hunger.Value)
	end
	return
end

return {
	["Dough"] = genericEat,
	["Bread"] = genericEat,
	["Space Fruit"] = genericEat,
	["Cooked Space Fruit"] = genericEat,
}
