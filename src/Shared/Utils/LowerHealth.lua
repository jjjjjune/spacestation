local import = require(game.ReplicatedStorage.Shared.Import)
local OnPlayerKilledPlayer = import "Shared/Utils/OnPlayerKilledPlayer"
local OnPlayerKilledMonster = import "Shared/Utils/OnPlayerKilledMonster"
local OnPlayerDamagedPlayer = import "Shared/Utils/OnPlayerDamagedPlayer"
local OnPlayerDamagedMonster = import "Shared/Utils/OnPlayerDamagedMonster"

return function(owner, victim, amount)
	if victim.Humanoid.Health > 0 then
		victim.Humanoid.Health = victim.Humanoid.Health - amount
		if victim.Humanoid.Health <= 0 then
			local victimPlayer = game.Players:GetPlayerFromCharacter(victim)
			if victimPlayer then
				OnPlayerKilledPlayer(owner, victimPlayer)
			else
				OnPlayerKilledMonster(owner, victim)
			end
		else
			local victimPlayer = game.Players:GetPlayerFromCharacter(victim)
			if victimPlayer then
				OnPlayerDamagedPlayer(owner, victimPlayer, amount)
			else
				OnPlayerDamagedMonster(owner, victim, amount)
			end
		end
	else
		return
	end
end
