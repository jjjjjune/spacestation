local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")
local GetNearestItemOfNameToPosition = import "Shared/Utils/GetNearestItemOfNameToPosition"
local GetNearestTagToPosition = import "Shared/Utils/GetNearestTagToPosition"
local LowerHealth = import "Shared/Utils/LowerHealth"
local Drops = import "Shared/Data/Drops"
local GetPlayerDamage = import "Shared/Utils/GetPlayerDamage"
local HttpService = game:GetService("HttpService")

local FOOD_FIND_DISTANCE =  60
local EAT_DISTANCE = 7
local RUN_RADIUS = 120
local FOOD = "Cactus Fruit"
local DEFAULT_WALKSPEED = 8
local TAIL_SLAM_RANGE = 30

--[[
	makes fireball and produces 1x coal when it eats something
]]

local Dragon = {}
Dragon.__index = Dragon

function Dragon:onStartedWalking()
	Messages:send("PlayAnimation", self.model, "DragonWalk")
end

function Dragon:onStoppedWalking()
	Messages:send("StopAnimation", self.model, "DragonWalk")
end

function Dragon:eat(apple)
	if self.eating then
		return
	end
	if apple.Parent ~= workspace then
		self:onStoppedEating()
		return
	end
	self.eating = true
	local origin = self.model.Head.Position
	Messages:send("PlayAnimation",self.model, "DragonEat")
	spawn(function()
		wait(2)
		if apple.Parent == workspace and apple:FindFirstChild("Base") and (apple.Base.Position - origin).magnitude <= EAT_DISTANCE and self.eating  and (not self.dead) then
			Messages:send("PlaySound", "Eating", apple.Base.Position)
		else
			self:onStoppedEating()
			return
		end
		self:onSucessfullyAte(apple)
		self:onStoppedEating()
		apple:Destroy()
	end)
end

function Dragon:findFood(type)
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
		return true
	end
	return false
end

function Dragon:onStoppedEating()
	self.model.Humanoid.WalkSpeed= DEFAULT_WALKSPEED
	self.eating = false
end

function Dragon:walkTo(pos)
	if not pos then
		return
	end
	self.model.Humanoid:MoveTo(pos)
end

function Dragon:hasBuildingAttached()
	local shouldCalculate= false
	if not self.lastBuildingCheck then
		self.lastBuildingCheck = time()
		shouldCalculate = true
	else
		if time() - self.lastBuildingCheck > 5 then
			shouldCalculate = true
			self.lastBuildingCheck = time()
		end
	end
	if shouldCalculate then
		local parts = self.model.HumanoidRootPart:GetConnectedParts(true)
		for _, p in pairs(parts) do
			if CollectionService:HasTag(p.Parent, "Building") then
				self.lastBuildingResult =  true
			end
		end
	end
	return self.lastBuildingResult
end

function Dragon:resetIdle()
	local length = math.random(1, 3)
	self.nextIdle = time() + length
	local walkDistX = math.random(-90,90)
	local walkDistY =math.random(-90,90)
	self.idlePosition = self.spawnPos + Vector3.new(walkDistX,0,walkDistY)
end

function Dragon:idle()
	if not self.nextIdle then
		self:resetIdle()
	end
	if self:hasBuildingAttached() then
		self.idlePosition = self.model.HumanoidRootPart.Position
		self.nextIdle = time() + 2
	end
	if time() < self.nextIdle then
		self:walkTo(self.idlePosition)
	else
		self:resetIdle()
	end
end

local function getEnemies(character, start, range, angle)
	local enemies = {}
	local inserted = {}
	local vec1 = (start + Vector3.new(-range,-(range),-range))
	local vec2 = (start + Vector3.new(range,(range),range))
	local region = Region3.new(vec1, vec2)
	local parts = workspace:FindPartsInRegion3(region,nil, 10000)
	for _, part in pairs(parts) do
		local humanoid = part.Parent:FindFirstChild("Humanoid")
		if humanoid and (humanoid ~= character.Humanoid) then
			if not inserted[humanoid] then
				table.insert(enemies, {humanoid = humanoid, part = part})
				inserted[humanoid] = true
			end
		end
	end
	return enemies
end

function Dragon:findHuman()
	local character = GetNearestTagToPosition("Character", self.model.PrimaryPart.Position, RUN_RADIUS)
	return character
end

function Dragon:damagePlayersNear(pos)
	local enemies = getEnemies(self.model, pos, 7, 1000)
	for _, enemy in pairs(enemies) do
		local character = enemy.humanoid.Parent
		local wasRagdolled = CollectionService:HasTag(character, "Ragdolled")
		if not wasRagdolled then
			--Messages:send("RagdollCharacter", character, 1.5)
		end
		enemy.humanoid:TakeDamage(40)
		Messages:send("PlayParticle", "Sparks", 5, enemy.part.Position)
	end
end

function Dragon:tailSlam(character)
	spawn(function()
		-- checks for nearby characters, slams tail down if there's a target within range
		-- next approach might just be me making an animation that turns the whole ass boy around
		local walkTime = 4
		local frames = 20
		for _ = 1, frames do
			wait(walkTime/frames)
			local pos= (character.HumanoidRootPart.CFrame).p
			self:walkTo(pos)
			local flatVec = Vector3.new(1,0,1)
			if (character.Head.Position*flatVec - self.model.TailSegment3.Position*flatVec).magnitude < 12 then
				break
			end
		end
		Messages:send("PlayAnimation", self.model, "DragonTailSlap")
		spawn(function()
			wait(.2)
			Messages:send("PlaySound", "HitSlap2", self.model.TailSegment3.Position)
			self:damagePlayersNear(self.model.TailSegment3.Position)
			self.attackGoing = false
			wait(1)

		end)
	end)
end

function Dragon:fireball(character)
	spawn(function()
		self.model.Humanoid.WalkSpeed = 1

		local chargeTime = 2
		local frames = 20
		for _, p in pairs(self.model.FireballCharge.Attachment:GetChildren()) do
			if p:IsA("ParticleEmitter") then
				p.Enabled = true
			end
		end

		self.model.FireballCharge.Transparency = 0
		Messages:send("PlayAnimation", self.model, "DragonMouthOpen")

		for _ = 1, frames do
			wait(chargeTime/frames)
			local pos= (character.HumanoidRootPart.CFrame).p
			self.model.FireballCharge.Mesh.Scale = self.model.FireballCharge.Mesh.Scale + Vector3.new(.1,.1,.1)
			self:walkTo(pos)
		end

		local id = HttpService:GenerateGUID()
		local pos= (character.HumanoidRootPart.CFrame).p
		local cannonball = game.ReplicatedStorage.Assets.Items["Fireball"]
		Messages:send("CreateProjectile", id, self.model.FireballCharge.Position, pos, cannonball, self.model)
		Messages:send("PlaySound", "Cannonfire", self.model.HumanoidRootPart.Position)

		for _, p in pairs(self.model.FireballCharge.Attachment:GetChildren()) do
			if p:IsA("ParticleEmitter") then
				p.Enabled = false
			end
		end

		Messages:send("StopAnimation", self.model, "DragonMouthOpen")

		self.model.FireballCharge.Mesh.Scale = Vector3.new(.5,.5,.5)
		self.attackGoing = false
		self.model.FireballCharge.Transparency = 1
		self.model.Humanoid.WalkSpeed = DEFAULT_WALKSPEED
	end)
end

function Dragon:attack(character)
	if self.attackGoing then
		return
	end
	if not self.phase then
		self.phase = 1
	end
	self:walkTo(character.Head.Position)
	if self.phase < 3 then
		Messages:send("PlayAnimation", self.model, "DragonTurnaround")
		--if (character.Head.Position - self.model.HumanoidRootPart.Position).magnitude < TAIL_SLAM_RANGE then
		self.attackGoing = true
		self:tailSlam(character)
		self.phase = self.phase + 1
		--end
	else
		Messages:send("StopAnimation", self.model, "DragonTurnaround")
		self.attackGoing = true
		self:fireball(character)
		self.phase = 1
	end
end

function Dragon:step()
	if self.dead then
		return
	end
	if not self:findFood(FOOD) then
		if not self.eating then
			local character = self:findHuman()
			if character then
				self:attack(character)
				if not self.attacking then
					self.attacking = true
					Messages:send("PlayAnimation", self.model, "DragonTailRaised")
				end
			else
				Messages:send("StopAnimation", self.model, "DragonTurnaround")
				if self.attacking then
					self.attacking = false
					Messages:send("StopAnimation", self.model, "DragonTailRaised")
				end
				self:idle()
			end
		else
			Messages:send("StopAnimation", self.model, "DragonTurnaround")
			if self.attacking then
				self.attacking = false
				Messages:send("StopAnimation", self.model, "DragonTailRaised")
			end
		end
	else
		if self.attacking then
			self.attacking = false
			Messages:send("StopAnimation", self.model, "DragonTailRaised")
		end
		self:idle()
	end
end

function Dragon:onSpawn()
	self.spawnPos = self.model.HumanoidRootPart.Position
end

function Dragon:onSucessfullyAte(apple)
	if apple:FindFirstChild("Base") then
		local r = Ray.new(apple.Base.Position, Vector3.new(0,-10,0))
		local _, pos = workspace:FindPartOnRay(r, apple)
		Messages:send("MakeItem", "Coal", pos)
		Messages:send("PlayParticle", "CookSmoke", 15, pos)
	end
end

function Dragon:init()
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
end

function Dragon:onDied()
	self.eating = false
	self.dead = true
	self.model:SetPrimaryPartCFrame(self.model.PrimaryPart.CFrame * CFrame.new(0,0,0))
	local anims = self.model.Humanoid:GetPlayingAnimationTracks()
	for _, anim in pairs(anims) do  anim:Stop() end
	Messages:send("PlayParticle", "Skulls", 20, self.model.Head.Position)
	self.model.LeftEye.BrickColor = BrickColor.new("White")
	self.model.RightEye.BrickColor = BrickColor.new("White")
	--self.model.Name = self.model.Name.." Corpse"
	--CollectionService:AddTag(self.model, "Ragdolled")
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
		Messages:send("MakeItem", "Dragon Egg", pos)
	end
end

function Dragon.new(model)
	local self = {}
	self.model = model
	setmetatable(self, Dragon)

	return self
end

return Dragon
