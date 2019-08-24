local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local LowerHealth = import "Shared/Utils/LowerHealth"
local HttpService = game:GetService("HttpService")

local tweenInfo = TweenInfo.new(
		.4, -- Time
		Enum.EasingStyle.Back, -- EasingStyle
		Enum.EasingDirection.Out
	)

	local tweenInfo2 = TweenInfo.new(
		.2, -- Time
		Enum.EasingStyle.Quint, -- EasingStyle
		Enum.EasingDirection.Out
	)

local MAX_RANGE = 40
local COUGH_UP_ITEM = "Water"
local ATTACK_DEBOUNCE = 2
local MAX_PLANT_RANGE = 50

local Weed = {}
Weed.__index = Weed

function Weed:closeHumanNonAlien()
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

function Weed:closeHuman()
	local closeHuman = nil
	local closestDistance = MAX_RANGE
	for _, p in pairs(game.Players:GetPlayers()) do
		local character = p.Character
		if character then
			local root = character.PrimaryPart
			if root then
				local distance = (root.Position - self.initialPos).magnitude
				if distance < closestDistance then
					closeHuman = character
					closestDistance = distance
				end
			end
		end
	end
	return closeHuman
end

function Weed:closePlant()
	local closeHuman = nil
	local closestDistance = MAX_PLANT_RANGE
	for _, character in pairs(CollectionService:GetTagged("Plant")) do
		local root = character.PrimaryPart
		if root then
			local distance = (root.Position - self.initialBallPos).magnitude
			if distance < closestDistance and character.Water.Value > 0 then
				local origin = self.initialBallPos
				local goal = root.Position
				local r = Ray.new(origin, (goal - origin).unit * 80)
				local hit, pos = workspace:FindPartOnRay(r, self.model)
				if (not hit) or (hit and hit.Parent == character) then
					closeHuman = character
					closestDistance = distance
				end
			end
		end
	end
	return closeHuman
end

function Weed:closePlantDry()
	local closeHuman = nil
	local closestDistance = MAX_PLANT_RANGE
	local ignorePlant
	if self.unchangedHealthCounter > 3 then
		ignorePlant = self.lastPlantAttacked
	end
	for _, character in pairs(CollectionService:GetTagged("Plant")) do
		local root = character.PrimaryPart
		if root then
			local distance = (root.Position - self.initialBallPos).magnitude
			if distance < closestDistance and character.Water.Value < character.Water.MaxValue and character ~= ignorePlant then
				local origin = self.initialBallPos
				local goal = root.Position
				local r = Ray.new(origin, (goal - origin).unit * 80)
				local hit, pos = workspace:FindPartOnRay(r, self.model)
				if (not hit) or (hit and hit.Parent == character) then
					closeHuman = character
					closestDistance = distance
				end
			end
		end
	end
	return closeHuman
end

function Weed:attack(character)
	if not self.lastAttack then
		self.lastAttack = time()
	end
	if time() - self.lastAttack > ATTACK_DEBOUNCE then
		local p = self.initialCF.p
		local goalPos = Vector3.new(character.PrimaryPart.Position.X, p.Y, character.PrimaryPart.Position.Z)
		local cf = CFrame.new(self.model.Ball.Position, goalPos)
		self.model.Ball.BodyGyro.CFrame = cf
		local origin = self.model.Ball.Position
		self.lastAttack = time()
		Messages:send("PlaySound", "Laser", origin)
		Messages:send("PlayParticle", "Sparks", 10, self.model.Ball.Position)
		local id = HttpService:GenerateGUID()
		local cannonball = game.ReplicatedStorage.Assets.Projectiles["Water Bullet"]
		if not CollectionService:HasTag(self.model, "Friendly") then
			cannonball = game.ReplicatedStorage.Assets.Projectiles["Bullet"]
		end
		if CollectionService:HasTag(character, "Plant") and not CollectionService:HasTag(self.model, "Friendly") then
			if self.lastPlantAttacked == character then
				if character.Water.Value == self.lastPlantAttackedHealth then
					self.unchangedHealthCounter = self.unchangedHealthCounter + 1
				else
					self.unchangedHealthCounter = 0
				end
			else
				self.lastPlantAttacked = character
				self.unchangedHealthCounter = 0
			end
			self.lastPlantAttackedHealth = character.Water.Value
		end
		Messages:send("CreateProjectile", id, origin, character.PrimaryPart.Position, cannonball, self.model)
	end
end

function Weed:coughItem()
	local p = (self.model.PrimaryPart.CFrame * CFrame.new(0,0,-3)).p
	local model = game.ReplicatedStorage.Assets.Objects[COUGH_UP_ITEM]:Clone()
	model.Parent = workspace
	model.PrimaryPart = model.Base
	model:SetPrimaryPartCFrame(CFrame.new(p))
	Messages:send("PlaySound","AlienCough", p)
end

function Weed:raise()
	if self.raised == true then
		return
	end
	if not self.tweening then
		self.model.Stem.HeadHolder.Enabled = true
		local part = self.model.HumanoidRootPart
		self.tweening = true
		local tween = TweenService:Create(part, tweenInfo, {
			CFrame = self.initialCF
		})
		tween:Play()
		delay(.45, function()
			self.tweening = false
			self.raised = true
			self.model.Stem.HeadHolder.Enabled = false
		end)
	end
end

function Weed:lower()
	if self.raised == false then
		return
	end
	if not self.tweening then
		self.tweening = true
		self.model.Stem.HeadHolder.Enabled = true
		local part = self.model.HumanoidRootPart
		local tween = TweenService:Create(part, tweenInfo, {
			CFrame = self.initialCF * CFrame.new(0,-16,0)
		})
		tween:Play()
		delay(.45, function()
			self.raised = false
			self.tweening = false
			self.model.Stem.HeadHolder.Enabled = false
		end)
	end
end

function Weed:friendlyStep()
	local plant = self:closePlantDry()
	if plant then
		self:raise()
		self:attack(plant)
	end
end

function Weed:hostileStep()
	local human = self:closeHumanNonAlien()
	local plant = self:closePlant()
	if human then
		self:raise()
		self:attack(human)
	elseif plant then
		self:raise()
		self:attack(plant)
	else
		self:lower()
	end
end

function Weed:step()
	if CollectionService:HasTag(self.model, "Friendly") then
		self:friendlyStep()
	else
		self:hostileStep()
	end
end

function Weed:onSpawn()

end

function Weed:init()
	self.raised = true
	self.spawn = time()
	self.initialPos = self.model.HumanoidRootPart.Position
	self.initialCF = self.model.HumanoidRootPart.CFrame
	self.initialBallPos = self.model.Ball.Position
	self.lastAttackPlantHealth = 1000
	self.lastPlantAttacked = nil
	self.unchangedHealthCounter = 0
	local connect
	connect = game:GetService("RunService").Stepped:connect(function()
		if self.dead then
			connect:disconnect()
		else
			self:step()
		end
	end)
end

function Weed:onDied()
	self.dead = true
	self.model.HumanoidRootPart.Anchored = false
	self.model.HumanoidRootPart:BreakJoints()
	for _, v in pairs(self.model:GetChildren()) do
		if v:IsA("BasePart") then
			v.CanCollide = true
			v.Anchored = false
		end
	end
	Messages:send("PlaySound", "AlienNoise1",self.model.PrimaryPart.Position)
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

function Weed.new(model)
	local self = {}
	self.model = model
	setmetatable(self, Weed)

	return self
end

return Weed
