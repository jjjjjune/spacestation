local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local GetProjectileDamageModifier = import "Shared/Utils/GetProjectileDamageModifier"
local ApplyExplosionDamage = import "Shared/Utils/ApplyExplosionDamage"

return {
	Dart = function(hit, owner, pos, projectileName)
		if not hit then
			return
		end
		local humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local mod = 1
			if owner then
				mod = GetProjectileDamageModifier(owner)
			end
			Messages:send("DamageHumanoid", humanoid, 45*mod, projectileName)
		else
			Messages:send("MakeItem", projectileName, pos)
		end
	end,
	["Iron Spear"] = function(hit, owner, pos, projectileName)
		if not hit then
			return
		end
		local humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local mod = 1
			if owner then
				mod = GetProjectileDamageModifier(owner)
			end
			Messages:send("DamageHumanoid", humanoid, 65*mod, projectileName)
		end
	end,
	["Bone Spear"] = function(hit, owner, pos, projectileName)
		if not hit then
			return
		end
		local humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local mod = 1
			if owner then
				mod = GetProjectileDamageModifier(owner)
			end
			Messages:send("DamageHumanoid", humanoid, 55*mod, projectileName)
		end
	end,
	["Stone Spear"] = function(hit, owner, pos, projectileName)
		if not hit then
			return
		end
		local humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local mod = 1
			if owner then
				mod = GetProjectileDamageModifier(owner)
			end
			Messages:send("DamageHumanoid", humanoid, 45*mod, projectileName)
		else
			Messages:send("MakeItem", projectileName, pos)
		end
	end,
	["Spear"] = function(hit, owner, pos, projectileName)
		if not hit then
			return
		end
		local humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local mod = 1
			if owner then
				mod = GetProjectileDamageModifier(owner)
			end
			Messages:send("DamageHumanoid", humanoid, 35*mod, projectileName)
		else
			Messages:send("MakeItem", projectileName, pos)
		end
	end,
	["Cactus Spine"] = function(hit, owner, pos, projectileName)
		if not hit then
			return
		end
		local humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local mod = 1
			if owner then
				mod = GetProjectileDamageModifier(owner)
			end
			Messages:send("DamageHumanoid", humanoid, 25*mod, projectileName)
		else
			Messages:send("MakeItem", projectileName, pos)
		end
	end,
	["Droolabou Egg"] = function(hit, owner, pos, projectileName)
		if hit then
			Messages:send("SpawnAnimal", owner, "Droolabou", pos)
			return true
		end
	end,
	["Turtle Egg"] = function(hit, owner, pos, projectileName)
		if hit then
			Messages:send("SpawnAnimal", owner, "Turtle", pos)
			return true
		end
	end,
	["Cactus Egg"] = function(hit, owner, pos, projectileName)
		if hit then
			Messages:send("SpawnAnimal", owner, "Cactus", pos)
			return true
		end
	end,
	["Jungle Queen Egg"] = function(hit, owner, pos, projectileName)
		if hit then
			Messages:send("SpawnAnimal", owner, "Queen", pos)
			return true
		end
	end,
	["Cannonball"] = function(hit, owner, pos, projectileName)
		local exp = Instance.new("Explosion", workspace)
		local alreadyHit = {}
		exp.Position = pos
		exp.DestroyJointRadiusPercent = 0
		exp.Hit:connect(function(hit)
			local hum = hit.Parent:FindFirstChild("Humanoid")
			if hum then
				if not alreadyHit[hum] then
					alreadyHit[hum] = true
					ApplyExplosionDamage(hum, 40)
				end
			end
		end)
		Messages:send("PlaySound", "Explosion", pos)
		return true
	end,
}
