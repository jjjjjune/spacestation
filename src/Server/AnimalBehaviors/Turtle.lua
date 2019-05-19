local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")
local GetNearestItemOfNameToPosition = import "Shared/Utils/GetNearestItemOfNameToPosition"
local GetNearestTagToPosition = import "Shared/Utils/GetNearestTagToPosition"
local LowerHealth = import "Shared/Utils/LowerHealth"
local Drops = import "Shared/Data/Drops"
local GetPlayerDamage = import "Shared/Utils/GetPlayerDamage"

local FOOD_FIND_DISTANCE =  60
local EAT_DISTANCE = 10
local DAMAGE_DEBOUNCE = 1
local DAMAGE = 30
local SPIKESDOWN_RADIUS = 30

local Turtle = {}
Turtle.__index = Turtle

function Turtle:canDamage()
	if not self.lastDamage then
		self.lastDamage = time()
	else
		if time() - self.lastDamage < DAMAGE_DEBOUNCE then
			return false
		end
	end
	if self.eating or self.dead then
		return false
	end
	return true
end

function Turtle:onHumanoidDamaged(humanoid)
	local character = humanoid.Parent
	if CollectionService:HasTag(character, "Character") then
		local knockbackForce = 20
		local wasRagdolled = CollectionService:HasTag(character, "Ragdolled")
		if not wasRagdolled then
			Messages:send("RagdollCharacter", character, 1.5)
		end

		local velocity = ((humanoid.RootPart.CFrame.lookVector.unit)*-knockbackForce)
		velocity = velocity + Vector3.new(0,500,0)
		humanoid.RootPart.Velocity = velocity

		local bv = humanoid.RootPart.BodyVelocity
		bv.Velocity = velocity
		bv.MaxForce = Vector3.new(1,1,1)*800

		spawn(function()
			wait(.2)
			bv.MaxForce = Vector3.new()
			wait(2)
			if not wasRagdolled then
				Messages:send("RagdollCharacter", character, -100)
			end
		end)
	else
		local knockbackForce = 20
		local velocity = ((humanoid.RootPart.CFrame.lookVector.unit)*-knockbackForce)
		velocity = velocity + Vector3.new(0,50,0)
		humanoid.RootPart.Velocity = velocity
		humanoid.Sit = true

		local bv = Instance.new("BodyVelocity", humanoid.RootPart)
		bv.Velocity = velocity
		bv.MaxForce = Vector3.new(1,3,1)*800

		spawn(function()
			wait(.2)
			bv:Destroy()
			wait(1)
			humanoid.Sit = false
		end)
	end
end

function Turtle:damage(humanoid)
	if not self:canDamage() then
		return
	end
	self.lastDamage = time()
	spawn(function()
		Messages:send("PlaySound", "HitStrong", self.model.HumanoidRootPart.Position)
		Messages:send("StopAnimation",self.model,"TurtleSpikesRetracted")
		Messages:send("PlayAnimation", self.model, "TurtleSpikesUp")

		LowerHealth(humanoid, DAMAGE, true)

		self:onHumanoidDamaged(humanoid)
	end)
end

function Turtle:onStartedWalking()
	Messages:send("PlayAnimation", self.model, "TurtleWalk")
end

function Turtle:onStoppedWalking()
	Messages:send("StopAnimation", self.model, "TurtleWalk")
end

function Turtle:onStoppedEating()
	Messages:send("StopAnimation", self.model, "TurtleSpikesRetracted")
	Messages:send("StopAnimation",self.model, "TurtleEat")
	Messages:send("PlayAnimation", self.model, "TurtleSpikesUp")
	self.model.Humanoid.WalkSpeed= 16
	self.eating = false
end

function Turtle:eat(apple)
	if self.eating then
		return
	end
	if apple.Parent ~= workspace then
		self:onStoppedEating()
		return
	end
	self.eating = true
	local origin = self.model.Head.Position
	Messages:send("PlayAnimation",self.model, "TurtleEat")
	Messages:send("PlayAnimation",self.model,"TurtleSpikesRetracted")
	spawn(function()
		for i = 1, 20 do
			if apple.Parent == workspace and apple:FindFirstChild("Base") and (apple.Base.Position - origin).magnitude <= EAT_DISTANCE and self.eating  and (not self.dead) then
				Messages:send("PlayParticle", "Eat",i, apple.Base.Position)
				Messages:send("PlaySound", "Eating", apple.Base.Position)
				wait(5/20)
			else
				self:onStoppedEating()
				return
			end
		end
		self:onStoppedEating()
		apple:Destroy()
	end)
end

function Turtle:findFood(type)
	local origin = self.model.Head.Position
	local apple, dist = GetNearestItemOfNameToPosition(type, origin, FOOD_FIND_DISTANCE)
	if apple then
		if dist < EAT_DISTANCE and (not self.eating) then
			self.model.Humanoid.WalkSpeed= 0
			self:walkTo(apple.Base.Position)
			self:eat(apple)
		else
			if not self.eating then
				self:walkTo(apple.Base.Position)
			end
		end
	end
	return apple
end

function Turtle:checkAttacker()
	local character = GetNearestTagToPosition("Character", self.model.PrimaryPart.Position, SPIKESDOWN_RADIUS)
	if character then
		if not self.attackerNear then
			self.attackerNear = true
			if not self.eating then
				Messages:send("PlaySound", "HeavyWhoosh", self.model.HumanoidRootPart.Position)
				Messages:send("PlayAnimation", self.model, "TurtleSpikesRetracted")
			end
		end
	else
		if self.attackerNear then
			if not self.eating then
				Messages:send("PlaySound", "HeavyWhoosh", self.model.HumanoidRootPart.Position)
				Messages:send("StopAnimation", self.model, "TurtleSpikesRetracted")
			end
			self.attackerNear = false
		end
	end
end

function Turtle:walkTo(pos)
	self.model.Humanoid:MoveTo(pos)
end

function Turtle:resetIdle()
	local length = math.random(1, 3)
	self.nextIdle = time() + length
	local walkDistX = math.random(-30,30)
	local walkDistY =math.random(-30,30)
	self.idlePosition = self.spawnPos + Vector3.new(walkDistX,0,walkDistY)
end

function Turtle:idle()
	if not self.nextIdle then
		self:resetIdle()
	end
	if time() < self.nextIdle then
		self:walkTo(self.idlePosition)
	else
		self:resetIdle()
	end
end

function Turtle:step()
	if not self:findFood("Apple") then
		if not self.eating then
			self:idle()
		end
	end
	self:checkAttacker()
end

function Turtle:onSpawn()
	self.spawnPos = self.model.HumanoidRootPart.Position
end

function Turtle:init()
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
	self.model.Hitbox.Touched:connect(function(hit)
		if self.dead then
			return
		end
		if hit.Parent:FindFirstChild("Humanoid") then
			self:damage(hit.Parent.Humanoid)
		end
	end)
end

function Turtle:onDied()
	self.eating = false
	self.dead = true
	self.model:SetPrimaryPartCFrame(self.model.PrimaryPart.CFrame * CFrame.new(0,0,0))
	local anims = self.model.Humanoid:GetPlayingAnimationTracks()
	for _, anim in pairs(anims) do  anim:Stop() end
	Messages:send("PlayParticle", "Skulls", 20, self.model.Head.Position)
	self.model.LeftEye.BrickColor = BrickColor.new("White")
	self.model.RightEye.BrickColor = BrickColor.new("White")
	self.model.FrontLeft.CanCollide = true
	self.model.BackRight.CanCollide = true
	self.model.FrontRight.CanCollide = true
	self.model.BackLeft.CanCollide = true
	self.model.Hitbox:Destroy()
	--self.model.Name = self.model.Name.." Corpse"
	--CollectionService:AddTag(self.model, "Ragdolled")
	Messages:send("PlaySound", "BoneBreak", self.model.Head.Position)
	game:GetService("Debris"):AddItem(self.model, 5)
	local drops = Drops[self.model.Name]
	local cframe = self.model.PrimaryPart.CFrame
	for _, itemName in pairs(drops) do
		local item = import("Assets/Items/"..itemName):Clone()
		item.Parent = workspace
		item.PrimaryPart = item.Base
		item:SetPrimaryPartCFrame(cframe * CFrame.new(math.random(-10,10), 5, math.random(-10,10)))
	end
end

function Turtle.new(model)
	local self = {}
	self.model = model
	setmetatable(self, Turtle)

	return self
end

return Turtle
