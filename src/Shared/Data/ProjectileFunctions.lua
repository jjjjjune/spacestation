local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local GetProjectileDamageModifier = import "Shared/Utils/GetProjectileDamageModifier"
local ApplyExplosionDamage = import "Shared/Utils/ApplyExplosionDamage"
local CollectionService = game:GetService("CollectionService")

local function genericHit(hit, owner, pos, projectileName, damage)
	if not hit then
		return
	end
	local humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
	if humanoid then
		local mod = 1
		if owner then
			mod = GetProjectileDamageModifier(owner)
		end
		Messages:send("DamageHumanoid", humanoid, damage*mod, projectileName, function(character)
			Messages:send("MakeItem", projectileName, pos)
		end)
	else
		Messages:send("MakeItem", projectileName, pos)
	end
end

local function burnPlantsNear(pos)
	for _, plant in pairs(CollectionService:GetTagged("Plant")) do
		if ((plant.Base.Position) - pos).magnitude < 10 then
			Messages:send("Burn", plant)
		end
	end
end

return {
	Default = function(hit, owner, pos, projectileName)
		genericHit(hit, owner, pos, projectileName, 10)
	end,
	Dart = function(hit, owner, pos, projectileName)
		genericHit(hit, owner, pos, projectileName, 20)
	end,
	["Iron Spear"] = function(hit, owner, pos, projectileName)
		genericHit(hit, owner, pos, projectileName, 55)
	end,
	["Bone Spear"] = function(hit, owner, pos, projectileName)
		genericHit(hit, owner, pos, projectileName, 45)
	end,
	["Stone Spear"] = function(hit, owner, pos, projectileName)
		genericHit(hit, owner, pos, projectileName, 40)
	end,
	["Spear"] = function(hit, owner, pos, projectileName)
		genericHit(hit, owner, pos, projectileName, 35)
	end,
	["Cactus Spine"] = function(hit, owner, pos, projectileName)
		genericHit(hit, owner, pos, projectileName, 25)
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
	["Dragon Egg"] = function(hit, owner, pos, projectileName)
		if hit then
			Messages:send("SpawnAnimal", owner, "Dragon", pos)
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
		exp.BlastPressure = 0
		exp.BlastRadius = 10
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
	["Fireball"] = function(hit, owner, pos, projectileName)
		Messages:send("PlayParticle", "CookSmoke", 15, pos)
		Messages:send("PlayParticle", "Sparks", 15, pos)
		local object = hit.Parent
		if object:FindFirstChild("Humanoid") then
			local mod = 1
			if owner then
				mod = GetProjectileDamageModifier(owner)
			end
			Messages:send("DamageHumanoid", hit.Parent.Humanoid, 50*mod, projectileName, function(character)
				Messages:send("Burn", character)
			end)
			for _, p in pairs(hit.Parent:GetChildren()) do
				if p:IsA("BasePart") and p.Material ~= Enum.Material.Neon then
					p.BrickColor = BrickColor.new("Black")
				end
			end
		else
			if CollectionService("HasTag", object, "Building") or CollectionService("HasTag", object, "Plant") then
				Messages:send("Burn", object)
			end
			burnPlantsNear(pos)
		end
		Messages:send("PlaySound", "Smoke", pos)
		return true
	end,
}
