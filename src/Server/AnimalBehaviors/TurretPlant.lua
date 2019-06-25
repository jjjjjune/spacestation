local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")
local GetNearestItemOfNameToPosition = import "Shared/Utils/GetNearestItemOfNameToPosition"
local GetNearestTagToPosition = import "Shared/Utils/GetNearestTagToPosition"
local LowerHealth = import "Shared/Utils/LowerHealth"
local TweenService = game:GetService("TweenService")
local Drops = import "Shared/Data/Drops"
local GetPlayerDamage = import "Shared/Utils/GetPlayerDamage"
local HttpService = game:GetService("HttpService")

local range = 300
local fireDebounce = 2
--[[
	makes fireball and produces 1x coal when it eats something
]]

local TurretPlant = {}
TurretPlant.__index = TurretPlant

function TurretPlant:step()
	if time() - self.lastFire < fireDebounce then
		return
	end
	local r = Ray.new(self.model.Barrel.Position, self.model.Base.CFrame.lookVector * range)
	local hit, pos = workspace:FindPartOnRay(r, self.model)
	if hit and hit.Anchored == false and hit.Parent.Name ~= "Dart" then
		self:fire(pos)
	end
end

function TurretPlant:fire(pos)
	self.lastFire = time()
	Messages:send("PlaySound", "DeepWhip", pos)
	local id = HttpService:GenerateGUID()
	local cannonball = game.ReplicatedStorage.Assets.Items["Dart"]
	Messages:send("CreateProjectile", id, self.model.Barrel.Position, pos, cannonball, self.model)
	self:onFire()
end

function TurretPlant:onFire()
	local tweenInfo = TweenInfo.new(
		.3, -- Time
		Enum.EasingStyle.Quad, -- EasingStyle
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(self.model.Barrel, tweenInfo, {CFrame = self.model.Barrel.CFrame * CFrame.Angles(0,math.rad(45), 0)})
	tween:Play()
end

function TurretPlant:onSpawn()
	self.lastFire = time()
	self.spawnPos = self.model.HumanoidRootPart.Position
end

function TurretPlant:init()
	Messages:hook("PlayerTriedDamageMonster", function(player, model, weaponData, part)
		if self.model == model then
			Messages:send("PlayParticle", "Shine", 1, part.Position)
			Messages:send("PlaySound", "HitSword", self.model.HumanoidRootPart.Position)
			local damage = GetPlayerDamage(player)
			self.model.Humanoid.Health = self.model.Humanoid.Health - damage
		end
	end)
	spawn(function()
		while wait() do
			self:step()
			if self.dead then
				break
			end
		end
	end)
end

function TurretPlant:onDied()
	self.dead = true
	Messages:send("PlayParticle", "Skulls", 20, self.model.Head.Position)
	for _, v in pairs(self.model:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = false
		end
	end
	Messages:send("PlaySound", "BoneBreak", self.model.Head.Position)
	game:GetService("Debris"):AddItem(self.model, 5)
	local drops = Drops[self.model.Name]
	local cframe = self.model.PrimaryPart.CFrame
	for _, itemName in pairs(drops) do
		local pos = cframe * CFrame.new(math.random(-10,10), 5, math.random(-10,10)).p
		Messages:send("MakeItem", itemName, pos)
	end
	if math.random(1, 50) == 1 then
		local pos = cframe * CFrame.new(math.random(-10,10), 5, math.random(-10,10)).p
		--Messages:send("MakeItem", "TurretPlant Egg", pos)
	end
end

function TurretPlant.new(model)
	local self = {}
	self.model = model
	setmetatable(self, TurretPlant)

	return self
end

return TurretPlant
