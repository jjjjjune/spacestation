local Cactus = {}
Cactus.__index = Cactus

local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Drops = import "Shared/Data/Drops"
local CollectionService = game:GetService("CollectionService")
local GetPlayerDamage = import "Shared/Utils/GetPlayerDamage"

local CHARGE_TIME = 2
local CHARGE_WALKSPEED =8
local ATTACK_RANGE = 10
local REGULAR_WALKSPEED = 18
local SIGHT_RANGE = 40
local ATTACK_DEBOUNCE = 5

Cactus.attackChargeBegin = tick()
Cactus.lastAttack = tick()

function Cactus:setExpression(expressionName)
	if not self.expression then
		self.expression = expressionName
	else
		self.model[self.expression].Transparency = 1
	end
	self.model[expressionName].Transparency = 0
	self.expression = expressionName
end

function Cactus:setAnimation(animationName, priority)
	priority = priority or "baseAnim"
	local animVar = priority
	if self[animVar] == animationName then
		return
	else
		if not self[animVar] then
			self[animVar] = animationName
		else
			Messages:send("StopAnimation", self.model, self[animVar])
		end
	end
	self[animVar] = animationName
	Messages:send("PlayAnimation", self.model, animationName)
end

function Cactus:stopAnimations(priority)
	if self[priority] then
		Messages:send("StopAnimation", self.model, self[priority])
		self[priority] = nil
	end
end

function Cactus:onAttack()
	local tweenInfo = TweenInfo.new(
		.2,
		Enum.EasingStyle.Bounce,
		Enum.EasingDirection.Out,
		0
	)
	local tween = TweenService:Create(self.model.Spikes.Mesh,tweenInfo, {Scale = Vector3.new(1.5,1.5,1.5)})
	tween:Play()
	spawn(function()
		Messages:send("PlaySound", "HitStrong", self.model.HumanoidRootPart.Position)
		local exp = Instance.new("Explosion", workspace)
		exp.Position = self.model.HumanoidRootPart.Position
		exp.BlastRadius = ATTACK_RANGE
		exp.BlastPressure = 0
		exp.DestroyJointRadiusPercent= 0
		exp.Visible = false
		local damaged = {}
		exp.Hit:connect(function(hit)
			local character = hit.Parent
			if damaged[character] then
				return
			else
				damaged[character] = true
			end
			if character:FindFirstChild("Humanoid") and character ~= self.model then
				local knockbackForce = 100
				local wasRagdolled = CollectionService:HasTag(character, "Ragdolled")
				if not wasRagdolled then
					Messages:send("RagdollCharacter", character, 1.5)
				end
				local humanoid = character.Humanoid
				humanoid:TakeDamage(35)
				local velocity = ((humanoid.RootPart.CFrame.lookVector.unit)*-knockbackForce)
				velocity = velocity + Vector3.new(0,50,0)
				humanoid.RootPart.Velocity = velocity

				local bv = humanoid.RootPart.BodyVelocity
				bv.Velocity = velocity
				bv.MaxForce = Vector3.new(1,1,1)*8000

				spawn(function()
					wait(.2)
					bv.MaxForce = Vector3.new()
					wait(2)
					if not wasRagdolled then
						Messages:send("RagdollCharacter", character, -100)
					end
				end)
			end
		end)
		Debris:AddItem(exp, 2)
		wait(1)
		local tweenInfo = TweenInfo.new(
			.2,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out,
			0
		)
		local tween = TweenService:Create(self.model.Spikes.Mesh,tweenInfo, {Scale = Vector3.new(.5,.5,.5)})
		tween:Play()
		Messages:send("PlaySound", "HeavyWhoosh", self.model.HumanoidRootPart.Position)
	end)
end

function Cactus:doAttack()
	if tick() - self.lastAttack < ATTACK_DEBOUNCE then
		self:stopAnimations("Attack")
		self.charging = false
		self:setExpression("Angry")
		return
	end
	if not self.charging then
		self.charging = true
		self.attackChargeBegin = tick()
	else
		self.model.Humanoid.WalkSpeed = CHARGE_WALKSPEED
	end
	self:setAnimation("CactusArmRaise", "Attack")
	if tick() - self.attackChargeBegin > CHARGE_TIME then
		Messages:send("PlayAnimation", self.model, "CactusAttack")
		self.attackChargeBegin = tick()
		self.model.Humanoid.WalkSpeed = REGULAR_WALKSPEED
		self:onAttack()
		self.lastAttack = tick()
	end
end

function Cactus:playerWithinRange(range)
	local closestDistance = range
	local closestPlayer = nil
	for _, player in pairs(game.Players:GetPlayers()) do
		local character = player.Character
		if character then
			local root = character.PrimaryPart
			if root then
				if (root.Position - self.model.PrimaryPart.Position).magnitude < closestDistance then
					closestDistance = (root.Position - self.model.PrimaryPart.Position).magnitude
					closestPlayer = player
				end
			end
		end
	end
	return closestPlayer
end

function Cactus:shouldSleep()
	if self:playerWithinRange(SIGHT_RANGE) then
		return false
	else
		return true
	end
end

function Cactus:onHit()
	Messages:send("PlayAnimation", self.model, "CactusHit1")
end
function Cactus:onSpawn()
	self.originalPosition = self.model.HumanoidRootPart.Position
end

function Cactus:sleep()
	self:stopAnimations("Attack")
	self:stopAnimations("Attack2")
	self:setAnimation("CactusSleep")
	self.model.Humanoid.WalkSpeed = 0
	self:setExpression("Sleepy")
	self.charging = false
end

function Cactus:onDied()
	self.dead = true
	local anims = self.model.Humanoid:GetPlayingAnimationTracks()
	for _, anim in pairs(anims) do  anim:Stop() end
	Messages:send("PlayParticle", "Skulls", 20, self.model.Head.Position)
	Messages:send("PlaySound", "BoneBreak", self.model.Head.Position)
	game:GetService("Debris"):AddItem(self.model, 5)
	local drops = Drops[self.model.Name]
	local cframe = self.model.PrimaryPart.CFrame
	for _, itemName in pairs(drops) do
		local pos = cframe * CFrame.new(math.random(-10,10), 5, math.random(-10,10)).p
		Messages:send("MakeItem", itemName, pos)
	end
	if math.random(1, 10) == 1 then
		local pos = cframe * CFrame.new(math.random(-10,10), 5, math.random(-10,10)).p
		Messages:send("MakeItem", "Cactus Egg", pos)
	end
end

function Cactus:stepFunction()
	if self.dead then return end
	if self:shouldSleep() then
		if (self.model.HumanoidRootPart.Position - self.originalPosition).magnitude < 20 then
			self:sleep()
		else
			self.model.Humanoid.WalkSpeed = REGULAR_WALKSPEED
			self.model.Humanoid:MoveTo(self.originalPosition)
			self:setAnimation("CactusWalk")
		end
	else
		local player = self:playerWithinRange(SIGHT_RANGE)
		self.model.Humanoid.WalkSpeed = REGULAR_WALKSPEED
		self.model.Humanoid:MoveTo(player.Character.HumanoidRootPart.Position)
		self:setAnimation("CactusWalk")
		self:setExpression("Angry")
		self:doAttack()
	end
end

function Cactus:init()
	Messages:hook("PlayerTriedDamageMonster", function(player, model, weaponData, part)
		if self.model == model then
			Messages:send("PlayParticle", "Shine", 1, part.Position)
			Messages:send("PlaySound", "HitSword", self.model.HumanoidRootPart.Position)
			local damage = GetPlayerDamage(player)
			self.model.Humanoid.Health = self.model.Humanoid.Health - damage
		end
	end)
	self.step = RunService.Stepped:connect(function()
		self:stepFunction()
	end)
	self.model.Humanoid.HealthChanged:connect(function()
		local health = self.model.Humanoid.Health
		if not self.lastHealth then
			self.lastHealth = health
			self:onHit()
		else
			if health < self.lastHealth then
				self:onHit()
			end
			self.lastHealth = health
		end
	end)
end

function Cactus:destroy()
	self.step:disconnect()
end

function Cactus.new(model)
	local self = {}
	self.model = model
	return setmetatable(self, Cactus)
end

return Cactus
