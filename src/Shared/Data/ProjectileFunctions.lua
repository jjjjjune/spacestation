local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local GetProjectileDamageModifier = import "Shared/Utils/GetProjectileDamageModifier"
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local LowerHealth = import "Shared/Utils/LowerHealth"
local Tame = import "Shared/Utils/Tame"


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
			Messages:send("PlayAnimation", humanoid.Parent, "Hit2")
			Messages:send("Knockback", hit.Parent, direction*60,.4)
		end
	end
	if (not owner) and CollectionService:HasTag(hit.Parent, "Plant") then
		hit.Parent.Water.Value = hit.Parent.Water.Value - 1
		Messages:send("PlaySound", "Leaves", hit.Position)
		Messages:send("PlayParticle", "Leaf", 15, hit.Position)
	end
	Messages:send("HeatContact", pos)
end

return {
	Default = function(hit, owner, pos, projectileName, direction)
		genericHit(hit, owner, pos, projectileName, 10, direction)
	end,
	Bullet = function(hit, owner, pos, projectileName, direction)
		genericHit(hit, owner, pos, projectileName, 10, direction)
	end,
	["Friend Bullet"] = function(hit, owner, pos, projectileName, direction)
		local humanoid = hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local character = humanoid.Parent
			if CollectionService:HasTag(character, "Animal") then
				Tame(owner, character)
			end
		end
	end,
}
