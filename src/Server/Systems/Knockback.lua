local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local KNOCKBACK_LENGTH = .3
local knockbackedCharacters = {}

local Knockback = {}

function Knockback:start()
	Messages:hook("Knockback", function(character, direction, t)
		local player = game.Players:GetPlayerFromCharacter(character)
		if player then
			Messages:sendClient(player, "Knockback",direction)
		else
			knockbackedCharacters[character] = {
				start = time(),
				direction = direction,
				length = t or KNOCKBACK_LENGTH,
			}
		end
	end)
	game:GetService("RunService").Stepped:connect(function()
		for character, characterInfo in pairs(knockbackedCharacters) do
			if time() - characterInfo.start <characterInfo.length then
				character.HumanoidRootPart.Velocity = characterInfo.direction
			end
		end
	end)
end

return Knockback
