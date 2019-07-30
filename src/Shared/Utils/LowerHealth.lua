local import = require(game.ReplicatedStorage.Shared.Import)
local OnPlayerKilledPlayer = import "Shared/Utils/OnPlayerKilledPlayer"
local OnPlayerKilledMonster = import "Shared/Utils/OnPlayerKilledMonster"
local OnPlayerDamagedPlayer = import "Shared/Utils/OnPlayerDamagedPlayer"
local OnPlayerDamagedMonster = import "Shared/Utils/OnPlayerDamagedMonster"
local CollectionService = game:GetService("CollectionService")

local badRoles  = {
	"Criminal",
	"Alien",
	"CausedExplosion",
}

local canHarmRoles = {
	"Alien"
}

return function(owner, victim, amount)
	local victimPlayer = game.Players:GetPlayerFromCharacter(victim)
	if owner and owner.Parent == game.Players then
		if victimPlayer then
			local badRole = false
			for _, role in pairs(badRoles) do
				if CollectionService:HasTag(victim, role) then
					badRole = true
				end
			end
			for _, role in pairs(canHarmRoles) do
				if CollectionService:HasTag(owner.Character, role) then
					badRole = true
				end
			end
			if badRole == false then
				-- you can't harm this player
				return
			end
		end
	end
	if owner and owner.Parent == game.Players then
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
	else
		-- a monster or statis world thing did this damage
		victim.Humanoid.Health = victim.Humanoid.Health - amount
	end
end
