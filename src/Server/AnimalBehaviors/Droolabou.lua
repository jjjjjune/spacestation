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
local RUN_RADIUS = 70
local FOOD = "Apple Seed"

local Droolabou = {}
Droolabou.__index = Droolabou

function Droolabou:onStartedWalking()
	Messages:send("PlayAnimation", self.model, "DroolWalk")
end

function Droolabou:onStoppedWalking()
	Messages:send("StopAnimation", self.model, "DroolWalk")
end

function Droolabou:onStoppedEating()
	Messages:send("StopAnimation",self.model, "DroolEat")
	self.model.Humanoid.WalkSpeed= 24
	self.eating = false
end

function Droolabou:onSucessfullyAte(apple)
	if apple:FindFirstChild("Base") then
		local r = Ray.new(apple.Base.Position, Vector3.new(0,-10,0))
		local _, pos = workspace:FindPartOnRay(r, apple)
		Messages:send("CreatePlant", nil, "Apple Tree", pos)
	end
end

function Droolabou:eat(apple)
	if self.eating then
		return
	end
	if apple.Parent ~= workspace then
		self:onStoppedEating()
		return
	end
	Messages:send("PlaySound", "Drool2", self.model.Head.Position)
	self.eating = true
	local origin = self.model.Head.Position
	Messages:send("PlayAnimation",self.model, "DroolEat")
	spawn(function()
		for i = 1, 20 do
			if apple.Parent == workspace and apple:FindFirstChild("Base") and (apple.Base.Position - origin).magnitude <= EAT_DISTANCE and self.eating  and (not self.dead) then
				Messages:send("PlayParticle", "Eat",i, apple.Base.Position)
				Messages:send("PlaySound", "Eating", apple.Base.Position)
				wait(2/20)
			else
				self:onStoppedEating()
				return
			end
		end
		self:onSucessfullyAte(apple)
		self:onStoppedEating()
		apple:Destroy()
	end)
end

function Droolabou:findFood(type)
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

function Droolabou:run(character)
	if not self.runPoint then
		self.runPoint = self.spawnPos + Vector3.new(math.random(-200,200), 0, math.random(-200,200))
		self.runStart =time()
	else
		if time() - self.runStart > 7 then
			self.runPoint = nil
			if math.random(1, 3) == 1 then
				Messages:send("PlaySound", "Drool1", self.model.Head.Position)
			end
		end
	end
	self.idlePosition = self.runPoint
	self:walkTo(self.runPoint)
end

function Droolabou:checkAttacker()
	local character = GetNearestTagToPosition("Character", self.model.PrimaryPart.Position, RUN_RADIUS)
	if character then
		if not self.attackerNear then
			self.attackerNear = true
			if not self.eating then

			end
		end
		self:run(character)
	else
		if self.attackerNear then
			if not self.eating then

			end
			self.attackerNear = false
		end
	end
end

function Droolabou:walkTo(pos)
	if not pos then
		return
	end
	self.model.Humanoid:MoveTo(pos)
end

function Droolabou:hasBuildingAttached()
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

function Droolabou:resetIdle()
	local length = math.random(1, 3)
	self.nextIdle = time() + length
	local walkDistX = math.random(-30,30)
	local walkDistY =math.random(-30,30)
	self.idlePosition = self.spawnPos + Vector3.new(walkDistX,0,walkDistY)
	if math.random(1, 20) == 1 then
		Messages:send("PlaySound", "Drool2", self.model.Head.Position)
	end
end

function Droolabou:idle()
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

function Droolabou:step()
	if not self:findFood(FOOD) then
		self:checkAttacker()
		if not self.eating then
			self:idle()
		end
	end
end

function Droolabou:onSpawn()
	self.spawnPos = self.model.HumanoidRootPart.Position
end

function Droolabou:init()
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

function Droolabou:onDied()
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
		Messages:send("MakeItem", "Droolabou Egg", pos)
	end
end

function Droolabou.new(model)
	local self = {}
	self.model = model
	setmetatable(self, Droolabou)

	return self
end

return Droolabou
