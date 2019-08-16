local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local function genericEat(character, item)
	local player = game.Players:GetPlayerFromCharacter(character)
	if player then
		Messages:sendClient(player, "AddHunger", item.Hunger.Value)
	end
	return
end

local function turnInvisible(character, item)

end

return {
	["Dough"] = genericEat,
	["Bread"] = genericEat,
	["Space Fruit"] = genericEat,
	["Cooked Space Fruit"] = genericEat,
	["Questionable Substance"] = genericEat,
	["Cube of Transprency"] = turnInvisible,
}
