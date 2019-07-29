local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local LowerHealth = import "Shared/Utils/LowerHealth"
local  HttpService = game:GetService("HttpService")

--[[
function TurretPlant:onFire()
	local tweenInfo = TweenInfo.new(
		.3, -- Time
		Enum.EasingStyle.Quad, -- EasingStyle
		Enum.EasingDirection.Out
	)
	local tween = TweenService:Create(self.model.Barrel, tweenInfo, {CFrame = self.model.Barrel.CFrame * CFrame.Angles(0,math.rad(45), 0)})
	tween:Play()
end
]]

local tweenInfo = TweenInfo.new(
		.8, -- Time
		Enum.EasingStyle.Quad, -- EasingStyle
		Enum.EasingDirection.Out
	)

local MAX_RANGE = 30

local Greenling = {}
Greenling.__index = Greenling

function Greenling:onStartedWalking()
	Messages:send("PlayAnimation", self.model, "GreenlingWalk")
end

function Greenling:onStoppedWalking()
	Messages:send("StopAnimation", self.model, "GreenlingWalk")
end

function Greenling:walkTo(pos)
	self.model.Humanoid:MoveTo(pos)
end

function Greenling:resetIdle()
	local length = math.random(1, 3)
	self.nextIdle = time() + length
	local walkDistX = math.random(-30,30)
	local walkDistY =math.random(-30,30)
	Messages:send("PlaySound","AlienNoise1",self.model.PrimaryPart.Position)
	self.idlePosition = self.spawnPos + Vector3.new(walkDistX,0,walkDistY)
end

function Greenling:idle()
	if not self.nextIdle then
		self:resetIdle()
	end
	if time() < self.nextIdle then
		self:walkTo(self.idlePosition)
	else
		self:resetIdle()
	end
end

function Greenling:closeHumanNonAlien()
	local closeHuman = nil
	local closestDistance = MAX_RANGE
	for _, p in pairs(game.Players:GetPlayers()) do
		local character = p.Character
		if character then
			if not CollectionService:HasTag(character, "Alien") and not CollectionService:HasTag(character, "FriendOfAliens") then
				local root = character.PrimaryPart
				if root then
					local distance = (root.Position - self.model.PrimaryPart.Position).magnitude
					if distance < closestDistance then
						closeHuman = character
						closestDistance = distance
					end
				end
			end
		end
	end
	return closeHuman
end

function Greenling:attack(character)
	self.attacking = true
	local t = time()
	local goal = character.PrimaryPart.Position + Vector3.new(0,0,5)
	local flat = Vector3.new(1,0,1)
	spawn(function()
		repeat
			wait()
			self.model.Humanoid:MoveTo(goal)
		until
		(
			(not character.PrimaryPart) or
			(time() - t > 3) or
			((goal * flat - self.model.PrimaryPart.Position * flat).magnitude < 4)
		)
		if not character.PrimaryPart then
			self.attacking = false
			return
		end

		local origin = self.model.Head.Position
		Messages:send("PlayAnimation", self.model, "GreenlingAttack")
		self.model.HumanoidRootPart.BodyGyro.MaxTorque = Vector3.new(0,100000,0)
		self.model.HumanoidRootPart.BodyGyro.CFrame = CFrame.new(self.model.PrimaryPart.Position,character.PrimaryPart.Position)
		self.model.Eye2.Material = Enum.Material.Neon
		local tween = TweenService:Create(self.model.Eye2, tweenInfo, {Color = BrickColor.new("Bright purple").Color})
		Messages:send("PlaySound", "Sacrifice", character.PrimaryPart.Position)
		tween:Play()
		wait(1)

		self.model.HumanoidRootPart.BodyGyro.MaxTorque = Vector3.new(0,0,0)
		self.model.Eye2.BrickColor = BrickColor.new("Black")
		Messages:send("PlaySound", "Laser", origin)
		Messages:send("PlayParticle", "Sparks", 10, self.model.Eye2.Position)
		local id = HttpService:GenerateGUID()
		local cannonball = game.ReplicatedStorage.Assets.Projectiles["Alien"]
		Messages:send("CreateProjectile", id, origin, character.PrimaryPart.Position, cannonball, self.model)

		wait(1)
		self.model.Humanoid.WalkSpeed = 12
		self.attacking = false
	end)
end

function Greenling:step()
	local human = self:closeHumanNonAlien()
	if human then
		if self.attacking then
			return
		else
			self:attack(human)
		end
	else
		self:idle()
	end
end

function Greenling:onSpawn()
	self.spawnPos = self.model.HumanoidRootPart.Position
end

function Greenling:init()
	spawn(function()
		while wait() do
			if self.dead then
				break
			else
				self:step()
			end
		end
	end)
	self.model.Humanoid.Running:connect(function(speed)
		if speed > 0 then
			if not self.walking then
				self.walking = true
				self:onStartedWalking()
			end
		else
			if self.walking then
				self.walking = false
				self:onStoppedWalking()
			end
		end
	end)
end

function Greenling:onDied()
	self:onStoppedWalking()
	self.dead = true
	Messages:send("PlaySound", "AlienNoise2",self.model.PrimaryPart.Position)
	self.model.HumanoidRootPart.BodyGyro.MaxTorque = Vector3.new(0,0,10000)
	self.model.HumanoidRootPart.BodyGyro.CFrame = self.model.HumanoidRootPart.CFrame * CFrame.Angles(0,0,-math.pi/2)
	self.model.HumanoidRootPart.PointLight:Destroy()
	for _, p in pairs(self.model:GetChildren()) do
		if p:IsA("BasePart") then
			p.BrickColor = BrickColor.new("Black")
		end
	end
	Messages:send("PlayParticle", "CookSmoke", 15, self.model.PrimaryPart.Position)
	Messages:send("PlaySound", "Chop", self.model.PrimaryPart.Position)
	delay(15, function()
		self.model:Destroy()
	end)
end

function Greenling.new(model)
	local self = {}
	self.model = model
	setmetatable(self, Greenling)

	return self
end

return Greenling
