local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local GetProjectileDamageModifier = import "Shared/Utils/GetProjectileDamageModifier"
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local LowerHealth = import "Shared/Utils/LowerHealth"


local function genericHit(hit, owner, pos, projectileName, damage, direction)
	if not hit then
		return
	end
	local humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
	if humanoid then
		if humanoid.Health <= 0 then
			return
		end
		if humanoid.Parent:FindFirstChild("Riot Shield") then
			local start = humanoid.RootPart.Position
			local id = HttpService:GenerateGUID()
			local model = game.ReplicatedStorage.Assets.Projectiles.Bullet
			local target = (humanoid.RootPart.CFrame * CFrame.new(0,0,-100)).p
			Messages:send("CreateProjectile",id, start, target, model, humanoid.Parent)
			Messages:send("Knockback", hit.Parent, direction*40,.4)
		else
			LowerHealth(owner, humanoid.Parent, damage)
			Messages:sendAllClients("DoDamageEffect", humanoid.Parent)
			Messages:send("PlayAnimation", humanoid.Parent, "Hit2")
			Messages:send("Knockback", hit.Parent, direction*60,.4)
		end
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
	Default = function(hit, owner, pos, projectileName, direction)
		genericHit(hit, owner, pos, projectileName, 10, direction)
	end,
	Bullet = function(hit, owner, pos, projectileName, direction)
		genericHit(hit, owner, pos, projectileName, 10, direction)
	end,
	Dart = function(hit, owner, pos, projectileName, direction)
		genericHit(hit, owner, pos, projectileName, 20, direction)
	end,
	["Iron Spear"] = function(hit, owner, pos, projectileName, direction)
		genericHit(hit, owner, pos, projectileName, 55, direction)
	end,
	["Bone Spear"] = function(hit, owner, pos, projectileName, direction)
		genericHit(hit, owner, pos, projectileName, 45, direction)
	end,
	["Stone Spear"] = function(hit, owner, pos, projectileName, direction)
		genericHit(hit, owner, pos, projectileName, 40, direction)
	end,
	["Spear"] = function(hit, owner, pos, projectileName, direction)
		genericHit(hit, owner, pos, projectileName, 35, direction)
	end,
	["Cactus Spine"] = function(hit, owner, pos, projectileName, direction)
		genericHit(hit, owner, pos, projectileName, 25, direction)
	end,
	["Droolabou Egg"] = function(hit, owner, pos, projectileName, direction)
		if hit then
			Messages:send("SpawnAnimal", owner, "Droolabou", pos)
			return true
		end
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
			Messages:send("DamageHumanoid", hit.Parent.Humanoid, 50*mod, projectileName, owner, function(character)
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
