local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local LowerHealth = import "Shared/Utils/LowerHealth"
local HttpService = game:GetService("HttpService")

local DAMAGE = 10
local SPREAD = 1
local MAX_RANGE = 60
local TONGUE_RANGE = 40

local tweenInfo = TweenInfo.new(.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfoRope = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function ragdoll(character)
	if CollectionService:HasTag(character, "Ragdolled") then
		return
	end
	local physicsOwner = game.Players:GetPlayerFromCharacter(character)
	local playerOwner = nil
	if physicsOwner and not playerOwner then
		character.HumanoidRootPart:SetNetworkOwner(physicsOwner)
		Messages:send("RagdollCharacter", character)
		Messages:sendClient(physicsOwner,"RagdollCharacter", character)
	else
		if not playerOwner then
			Messages:send("RagdollCharacter", character)
		else
			Messages:send("RagdollCharacter", character)
			Messages:sendClient(playerOwner,"RagdollCharacter", character)
		end
	end
end

local function unragdoll(character)
	if not CollectionService:HasTag(character, "Ragdolled") then
		return
	end
	local physicsOwner = game.Players:GetPlayerFromCharacter(character)
	local playerOwner = nil
	if physicsOwner and not playerOwner then
		Messages:sendClient(physicsOwner, "UnragdollCharacter", character)
		Messages:send("UnragdollCharacter", character)
		character.HumanoidRootPart:SetNetworkOwner(physicsOwner)
	else
		if not playerOwner then
			Messages:send("UnragdollCharacter", character)
		else
			Messages:sendClient(playerOwner, "UnragdollCharacter", character)
			Messages:send("UnragdollCharacter", character)
		end
	end
end

local Blueling = {}
Blueling.__index = Blueling

function Blueling:onStartedWalking()
	Messages:send("PlayAnimation", self.model, "BluelingWalk")
end

function Blueling:onStoppedWalking()
	Messages:send("StopAnimation", self.model, "BluelingWalk")
end

function Blueling:walkTo(pos)
	self.model.Humanoid:MoveTo(pos)
end

function Blueling:resetIdle()
	local length = math.random(2, 7)
	self.nextIdle = time() + length
	local walkDistX = math.random(-30,30)
	local walkDistY =math.random(-30,30)
	Messages:send("PlaySound","AlienNoiseDeep1",self.model.PrimaryPart.Position)
	self.idlePosition = self.spawnPos + Vector3.new(walkDistX,0,walkDistY)
end

function Blueling:idle()
	if not self.nextIdle then
		self:resetIdle()
	end
	if time() < self.nextIdle then
		self:walkTo(self.idlePosition)
	else
		self:resetIdle()
	end
end

function Blueling:closeHumanNonAlien()
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
	return closeHuman, closestDistance
end

function Blueling:attack(character)
	local tongue = self.model.TonguePart
	self:playAttackAnimation()
	local player = game.Players:GetPlayerFromCharacter(character)
	if player then
		self.model.HumanoidRootPart:SetNetworkOwner(player)
	end
	--self.model.PrimaryPart.Anchored = true

	self.attacking = true

	self.model.MouthBottom.TongueRope.Length = 100
	local origin = self.model.Head.Position
	tongue.Beam.Enabled = true

	local start = character.HumanoidRootPart.Position + Vector3.new(math.random(-SPREAD,SPREAD), math.random(-SPREAD,SPREAD), math.random(-SPREAD,SPREAD))
	local r = Ray.new(tongue.Position, (start - tongue.Position).unit * TONGUE_RANGE)
	local hit, pos = workspace:FindPartOnRay(r, self.model)


	Messages:send("PlaySound", "Deflect4", tongue.Position)
	Messages:send("PlayParticle", "Sparks", 15, tongue.Position)

	local w = Instance.new("WeldConstraint", tongue)

	tongue.BodyPosition.MaxForce = Vector3.new(100000,100000,100000)
	if hit then
		tongue.BodyPosition.Position = hit.Position
	else
		tongue.BodyPosition.Position = (self.model.PrimaryPart.CFrame * CFrame.new(math.random(-10,10),0,-100)).p
	end

	wait(.05)

	if hit then
		tongue.CFrame = CFrame.new(hit.Position)
	else
		tongue.BodyPosition.MaxForce = Vector3.new()
	end

	if hit and hit.Parent:FindFirstChild("Humanoid") and not hit.Parent:FindFirstChild("Riot Shield") then
		w.Part0 = hit
		w.Part1 =tongue
		ragdoll(hit.Parent)
		character = hit.Parent
		Messages:send("PlaySound", "BoneBreak", tongue.Position)
		Messages:send("PlayParticle", "Sparks", 15, hit.Position)
		LowerHealth(self.model, hit.Parent, DAMAGE)
		self.runaway= true
	end

	wait(.2)

	local tween = TweenService:Create(self.model.MouthBottom.TongueRope,  tweenInfoRope, {Length = 0})
	tween:Play()
	wait(.4) -- how long it holds on to you with the tongue
	tongue.BodyPosition.MaxForce = Vector3.new(0,0,0)
	w:Destroy()
	self:stopAttackAnimation()
	--self.model.PrimaryPart.Anchored = false

	wait(1)
	tongue.Beam.Enabled = false
	spawn(function() unragdoll(character) end)

	if self.runaway == true then
		wait(8) -- it wont attack again for 8 seconds
	else
		self.runaway = true
		wait(2)
	end
	self.model.Humanoid.WalkSpeed = 12
	self.attacking = false
	self.runaway = false
end

function Blueling:playAttackAnimation()
	if not self.attackAnimPlaying then
		self.attackAnimPlaying = true
		Messages:send("PlayAnimation", self.model, "BluelingAttack")
		if time() - self.lastSound > 10 then
			Messages:send("PlaySound", "AlienHiss", self.model.PrimaryPart.Position)
			self.lastSound = time()
		end
	end
end

function Blueling:stopAttackAnimation()
	if self.attackAnimPlaying then
		self.attackAnimPlaying = false
		Messages:send("StopAnimation", self.model, "BluelingAttack")
	end
end

function Blueling:step()
	if self.runaway then
		self:idle()
		self.model.HumanoidRootPart.BodyGyro.MaxTorque = Vector3.new(0,0,0)
		return
	end
	local human, dist = self:closeHumanNonAlien()
	if human then
		if self.attacking then
			return
		else
			if dist < TONGUE_RANGE then
				local character = human
				self.model.HumanoidRootPart.BodyGyro.MaxTorque = Vector3.new(0,100000,0)
				self.model.HumanoidRootPart.BodyGyro.CFrame = CFrame.new(self.model.PrimaryPart.Position,character.PrimaryPart.Position)
				spawn(function() self:attack(human) end)
			else
				self.model.Humanoid:MoveTo(self.model.HumanoidRootPart.Position)
				local character = human
				self.model.HumanoidRootPart.BodyGyro.MaxTorque = Vector3.new(0,100000,0)
				self.model.HumanoidRootPart.BodyGyro.CFrame = CFrame.new(self.model.PrimaryPart.Position,character.PrimaryPart.Position)

				self:playAttackAnimation()
			end
		end
	else
		self.model.HumanoidRootPart.BodyGyro.MaxTorque = Vector3.new(0,0,0)
		self:stopAttackAnimation()
		self:idle()
	end
end

function Blueling:onSpawn()
	self.spawnPos = self.model.HumanoidRootPart.Position
end

function Blueling:init()
	self.lastSound = time()
	local connect
	connect = game:GetService("RunService").Stepped:connect(function()
		if self.dead then
			connect:disconnect()
		else
			self:step()
		end
	end)
	self.model.Humanoid.HealthChanged:connect(function() -- if it takes damage baby, then its go time
		if self.runaway == true then
			wait(1)
			self.runaway = false
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

function Blueling:onDied()
	self:onStoppedWalking()
	self.dead = true
	Messages:send("PlaySound", "AlienNoiseDeep2",self.model.PrimaryPart.Position)
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

function Blueling.new(model)
	local self = {}
	self.model = model
	setmetatable(self, Blueling)

	return self
end

return Blueling
