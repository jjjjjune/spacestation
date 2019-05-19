local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")
local GetNearestItemOfNameToPosition = import "Shared/Utils/GetNearestItemOfNameToPosition"
local GetNearestTagToPosition = import "Shared/Utils/GetNearestTagToPosition"
local LowerHealth = import "Shared/Utils/LowerHealth"
local Drops = import "Shared/Data/Drops"
local PhysicsService = game:GetService("PhysicsService")
local Data = import "Shared/PlayerData"
local GetPlayerDamage = import "Shared/Utils/GetPlayerDamage"

local EAT_TIME = 12
local DOWN_RADIUS = 35
local FOOD = "Green Mushroom"

local Queen = {}
Queen.__index = Queen


function Queen:findPrey()
	local r = Ray.new(self.model.Head.Position, Vector3.new(0,-300,0))
	local hit, pos = workspace:FindPartOnRay(r, self.model)
	if hit then
		if hit.Parent:FindFirstChild("Humanoid") then
			return hit.Parent
		end
	end
	local apple, _ = GetNearestItemOfNameToPosition(FOOD, pos, DOWN_RADIUS)
	if apple then
		return apple
	end
	local character = GetNearestTagToPosition("Character", pos, DOWN_RADIUS)
	if character then
		return character
	end
end

function Queen:canGoDown()
	local ropeRay = Ray.new(self.model.Head.Position, Vector3.new(0,-30,0))
	local hit, _ = workspace:FindPartOnRay(ropeRay, self.model)
	if hit == nil then
		return true
	else
		return false
	end
end

function Queen:canGoUp()
	local ropeRay = Ray.new(self.model.Back.Position, Vector3.new(0,8,0))
	local hit, _ = workspace:FindPartOnRay(ropeRay, self.model)
	if hit == nil then
		return true
	else
		return false
	end
end

function Queen:raise()
	if not self.retractPlaying then
		Messages:send("PlayAnimation", self.model, "SpiderRetract")
		self.retractPlaying = true
	end
	self.rope.Length = math.max(self.minRope, self.rope.Length - 1)
	if self.rope.Length == self.minRope then
		if self.retractPlaying then
			Messages:send("StopAnimation", self.model, "SpiderRetract")
			self.retractPlaying = false
		end
	end
end

function Queen:lower()
	if self.retractPlaying then
		Messages:send("StopAnimation", self.model, "SpiderRetract")
		self.retractPlaying = false
	end
	self.rope.Length = math.min(self.maxRope, self.rope.Length + 5)
end

function Queen:canEat()
	if time() - self.lastAte < EAT_TIME then
		return false
	end
	return true
end

function Queen:eat(model)
	if self.food then
		return
	end
	if not self.lastAte then
		self.lastAte =time()
	else
		if not self:canEat() then
			return
		end
	end
	if not self.foodAnimPlaying then
		Messages:send("PlayAnimation", self.model, "SpiderGrab")
		Messages:send("PlayAnimation", self.model, "SpiderHolding")
		self.foodAnimPlaying = true
	end
	self.lastAte =time()
	self.food = model
	local attachment1, attachment2
	if model:FindFirstChild("Head") then
		model.Head.CFrame = self.model.Head.CFrame
		attachment1 = Instance.new("Attachment", model.Head)
	else
		model:SetPrimaryPartCFrame(self.model.Head.CFrame)
		attachment1 = Instance.new("Attachment", model.PrimaryPart)
	end
	attachment2 = Instance.new("Attachment", self.model.Head)
	self.foodweld = Instance.new("RopeConstraint", attachment1.Parent)
	self.foodweld.Attachment0 = attachment1
	self.foodweld.Attachment1 = attachment2
	self.foodweld.Length = 3
	Messages:send("PlaySound", "HitSlap", self.model.Head.Position)
	spawn(function()
		if model:FindFirstChild("Humanoid") then
			Messages:send("RagdollCharacter", model, EAT_TIME + 1)
			spawn(function()
				local frames = 15
				for _ = 1, frames do
					wait(.25)
					Messages:send("PlayParticle", "Eat",15, attachment1.Position)
					Messages:send("PlaySound", "Eating", attachment1.Position)
					model.Humanoid.Health = model.Humanoid.Health - 2
				end
			end)
			local player = game.Players:GetPlayerFromCharacter(model)
			if player then
				Data:set(player, "lastHit", time())
			end
		end
		wait(EAT_TIME)
		self.lastAte =time()
		if model:FindFirstChild("Humanoid") then
			self.foodweld:Destroy()
		else
			self.food:Destroy()
		end
		self.food = nil
		if self.foodAnimPlaying then
			Messages:send("StopAnimation", self.model, "SpiderHolding")
			self.foodAnimPlaying = false
		end
	end)
end

function Queen:step()
	if not self.food then
		if self:findPrey() and self:canEat() then
			if self:canGoDown() then
				self:lower()
			end
		else
			if self:canGoUp() then
				self:raise()
			end
		end
	else
		if self:canGoUp() then
			self:raise()
		end
	end
end

function Queen:onSpawn()
	self.spawnPos = self.model.HumanoidRootPart.Position
	local ropeRay = Ray.new(self.model.HumanoidRootPart.Position, Vector3.new(0,15,0))
	local hit, pos = workspace:FindPartOnRay(ropeRay, self.model)
	local attachment1 = Instance.new("Attachment", self.model.Back)
	local attachment2 = Instance.new("Attachment", workspace.Terrain)
	attachment2.Position = pos
	local ropeLength = (pos - self.model.Back.Position).magnitude
	self.rope = Instance.new("RopeConstraint", self.model.Back)
	self.rope.Length = ropeLength
	self.rope.Color = BrickColor.new("Flint")
	self.rope.Thickness = .1
	self.rope.Attachment0 = attachment1
	self.rope.Attachment1 = attachment2
	self.rope.Visible = true

	self.minRope = ropeLength

	local r = Ray.new(self.model.Head.Position, Vector3.new(0,-300,0))
	local hit, pos = workspace:FindPartOnRay(r, self.model)
	if hit then
		self.maxRope = (pos - self.model.Head.Position).magnitude-1
	end

	self.startLength = ropeLength

	for _, part in pairs(self.model:GetChildren()) do
		if part:IsA("BasePart") then
			PhysicsService:SetPartCollisionGroup(part, "CharacterGroup")
		end
	end
end

function Queen:init()
	Messages:hook("PlayerTriedDamageMonster", function(player, model, weaponData, part)
		if self.model == model then
			Messages:send("PlayParticle", "Shine", 1, part.Position)
			Messages:send("PlaySound", "HitSword", self.model.HumanoidRootPart.Position)
			local damage = GetPlayerDamage(player)
			self.model.Humanoid.Health = self.model.Humanoid.Health - damage
			self.lastAte = time()
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
	self.model.Hitbox.Touched:connect(function(hit)
		if self.dead then
			return
		end
		if hit.Parent:FindFirstChild("Humanoid") or hit.Parent.Name == FOOD then
			self:eat(hit.Parent)
		end
	end)
end

function Queen:onDied()
	self.eating = false
	self.dead = true
	self.model:SetPrimaryPartCFrame(self.model.PrimaryPart.CFrame * CFrame.new(0,0,0))
	local anims = self.model.Humanoid:GetPlayingAnimationTracks()
	for _, anim in pairs(anims) do  anim:Stop() end
	Messages:send("PlayParticle", "Skulls", 20, self.model.Head.Position)
	self.model.Pupil.BrickColor = BrickColor.new("White")
	self.model.Hitbox:Destroy()
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

function Queen.new(model)
	local self = {}
	self.model = model
	self.lastAte =time()
	setmetatable(self, Queen)

	return self
end

return Queen
