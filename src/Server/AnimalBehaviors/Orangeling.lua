local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local LowerHealth = import "Shared/Utils/LowerHealth"
local HttpService = game:GetService("HttpService")

local tweenInfo = TweenInfo.new(
		.2, -- Time
		Enum.EasingStyle.Quint, -- EasingStyle
		Enum.EasingDirection.Out
	)

local MAX_RANGE = 60
local MAX_PLANT_RANGE = 60
local COUGH_UP_ITEM = "Fuel"
local COUGH_TIME = 120
local BLOW_RANGE = 20

local Orangeling = {}
Orangeling.__index = Orangeling

function Orangeling:onStartedWalking()
	Messages:send("PlayAnimation", self.model, "OrangelingWalk")
end

function Orangeling:onStoppedWalking()
	Messages:send("StopAnimation", self.model, "OrangelingWalk")
end

function Orangeling:walkTo(pos)
	self.model.Humanoid:MoveTo(pos)
end

function Orangeling:resetIdle()
	local length = math.random(1, 3)
	self.nextIdle = time() + length
	local walkDistX = math.random(-30,30)
	local walkDistY =math.random(-30,30)
	Messages:send("PlaySound","AlienNoise1",self.model.PrimaryPart.Position)
	self.idlePosition = self.spawnPos + Vector3.new(walkDistX,0,walkDistY)
end

function Orangeling:idle()
	if not self.nextIdle then
		self:resetIdle()
	end
	if time() < self.nextIdle then
		self:walkTo(self.idlePosition)
	else
		self:resetIdle()
	end
end

function Orangeling:closeHumanNonAlien()
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

function Orangeling:closeHuman()
	local closeHuman = nil
	local closestDistance = MAX_RANGE
	for _, p in pairs(game.Players:GetPlayers()) do
		local character = p.Character
		if character then
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
	return closeHuman
end

function Orangeling:closeEngine()
	local closeHuman = nil
	local closestDistance = MAX_PLANT_RANGE
	for _, character in pairs(CollectionService:GetTagged("Engine")) do
		local root = character.Base
		if root then
			local distance = (root.Position - self.model.PrimaryPart.Position).magnitude
			if distance < closestDistance then
				closeHuman = character
				closestDistance = distance
			end
		end
	end
	for _, character in pairs(CollectionService:GetTagged("Door")) do
		local root = character.Door
		if root then
			local distance = (root.Position - self.model.PrimaryPart.Position).magnitude
			if distance < closestDistance and character.OpenValue.Value == false then
				closeHuman = character
				closestDistance = distance
			end
		end
	end
	return closeHuman
end

function Orangeling:attack(character)
	if (self.model.PrimaryPart.Position - character.PrimaryPart.Position).magnitude > BLOW_RANGE then
		self:walkTo(character.PrimaryPart.Position)
		self.model.Humanoid.WalkSpeed = 5
		if self.attacking then
			self:cancelAttack()
		end
		return
	end
	self.model.Head.CookSmoke:Emit(30)
	--Messages:send("PlayParticle","Sparks", 15,self.model.Head.Position)
	Messages:send("PlaySound", "AlienNoise2",self.model.PrimaryPart.Position)
	self.attacking = true
	self.model.Humanoid.WalkSpeed = 5
	self:walkTo(character.PrimaryPart.Position)
	local tween = TweenService:Create(self.model.Head, tweenInfo, {
		Size = self.startSize *2
	})
	tween:Play()
	tween = TweenService:Create(self.model.Eye1, tweenInfo, {
		Size = self.eyeSize + Vector3.new(2,2,6),
	})
	tween:Play()
	tween = TweenService:Create(self.model.Eye2, tweenInfo, {
		Size = self.eyeSize + Vector3.new(2,2,6),
	})
	tween:Play()
	--[[tween = TweenService:Create(self.model.Antenna.Motor6D, tweenInfo, {
		C0 = self.starC0 * CFrame.new(0,3,0),
	})
	tween:Play()--]]
	tween = TweenService:Create(self.model.Head.AntennaMotor, tweenInfo, {
		C0 = self.antennaC0 * CFrame.new(0,0,3)
	})
	tween:Play()
	spawn(function()
		local t = .5
		for i = 1, 20 do
			wait(t)
			if self.attacking then
				t = t/1.1
				Messages:send("PlaySound", "BombTick", self.model.PrimaryPart.Position)
				if self.model.Star.BrickColor == BrickColor.new("Persimmon") then
					self.model.Star.BrickColor = BrickColor.new("Brick yellow")
				else
					self.model.Star.BrickColor = BrickColor.new("Persimmon")
				end
			else
				return
			end
		end
		if self.attacking then
			for _, p in pairs(self.model:GetChildren()) do
				if p:IsA("BasePart") then
					p.CanCollide = true
				end
			end
			Messages:send("CreateExplosion",self.model.PrimaryPart.Position, 30)
		end
	end)
end

function Orangeling:cancelAttack()
	self.attacking = false
	local tween = TweenService:Create(self.model.Head, tweenInfo, {
		Size = self.startSize
	})
	tween:Play()
	tween = TweenService:Create(self.model.Eye1, tweenInfo, {
		Size = self.eyeSize,
	})
	tween:Play()
	tween = TweenService:Create(self.model.Eye2, tweenInfo, {
		Size = self.eyeSize,
	})
	tween:Play()
	--[[tween = TweenService:Create(self.model.Antenna.Motor6D, tweenInfo, {
		C0 = self.starC0
	})
	tween:Play()--]]
	tween = TweenService:Create(self.model.Head.AntennaMotor, tweenInfo, {
		C0 = self.antennaC0
	})
	tween:Play()
	self.model.Humanoid.WalkSpeed = 16
end

function Orangeling:coughItem()
	local p = (self.model.PrimaryPart.CFrame * CFrame.new(0,0,-3)).p
	local model = game.ReplicatedStorage.Assets.Objects[COUGH_UP_ITEM]:Clone()
	model.Parent = workspace
	model.PrimaryPart = model.Base
	model:SetPrimaryPartCFrame(CFrame.new(p))
	Messages:send("PlaySound","AlienCough", p)
end

function Orangeling:friendlyStep()
	self.model.Humanoid.WalkSpeed = 16
	if self.attacking then
		self:cancelAttack()
	end
	if not self.lastCough then
		self.lastCough = time()
	end
	if time() - self.lastCough > COUGH_TIME then
		self:coughItem()
		self.lastCough = time()
	end
	if CollectionService:HasTag(self.model, "Following") then
		local human = self:closeHuman()
		if human then
			if not self.offset then
				self.offset = Vector3.new(math.random(-2,2), 0, math.random(-2,2))
			end
			local goal =human.PrimaryPart.Position + self.offset
			local dist = (self.model.PrimaryPart.Position - goal).magnitude
			if dist > 8 then
				self.model.Humanoid:MoveTo(goal)
				self.spawnPos = self.model.PrimaryPart.Position
			else
				self.model.Humanoid:MoveTo(self.model.PrimaryPart.Position)
			end
		else
			self:idle()
		end
	else
		self:idle()
	end
end

function Orangeling:hostileStep()
	local human = self:closeHumanNonAlien()
	local engine = self:closeEngine()
	if human then
		if self.attacking then
			return
		else
			self:attack(human)
		end
	elseif engine then
		if self.attacking then
			return
		else
			self:attack(engine)
		end
	else
		if self.attacking then
			self:cancelAttack()
		end
		self:idle()
	end
end

function Orangeling:step()
	if CollectionService:HasTag(self.model, "Friendly") then
		self:friendlyStep()
	else
		self:hostileStep()
	end
end

function Orangeling:onSpawn()
	self.spawnPos = self.model.HumanoidRootPart.Position
end

function Orangeling:init()
	local connect
	self.startSize = self.model.Head.Size
	self.eyeSize = self.model.Eye1.Size
	self.starC0 = self.model.Antenna.Motor6D.C0
	self.antennaC0 = self.model.Head.AntennaMotor.C0
	connect = game:GetService("RunService").Stepped:connect(function()
		if self.dead then
			connect:disconnect()
		else
			debug.profilebegin("greenlingstep")
			self:step()
			debug.profileend()
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

function Orangeling:onDied()
	self:onStoppedWalking()
	self.dead = true
	Messages:send("PlaySound", "AlienNoise2",self.model.PrimaryPart.Position)
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

function Orangeling.new(model)
	local self = {}
	self.model = model
	setmetatable(self, Orangeling)

	return self
end

return Orangeling
