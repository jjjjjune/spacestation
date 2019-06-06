local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local speed = 4
local checkRange = 4

local Projectile = {}
Projectile.__index = Projectile

function Projectile:anyNearbyPeople(start, range)
	local vec1 = (start + Vector3.new(-range,-(range),-range))
	local vec2 = (start + Vector3.new(range,(range),range))
	local region = Region3.new(vec1, vec2)
	local parts = workspace:FindPartsInRegion3(region,nil, 10000)
	for _, part in pairs(parts) do
		local humanoid = part.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local canReturn = true
			for _, ignore in pairs(self.ignored) do
				if part:IsDescendantOf(ignore) then
					canReturn = false
				end
			end
			if canReturn then
				return part
			end
		end
	end
end


function Projectile:tick(dt)
	if not self.model:FindFirstChild("Base") then
		self:destroy()
	end
	local r = Ray.new(self.model.Base.Position, self.model.Base.CFrame.lookVector * speed)
	local hit, pos = workspace:FindPartOnRayWithIgnoreList(r, self.ignored)
	local t = self.t or 0
	if not self.t then
		self.t = 0
	else
		self.t = self.t + dt
	end
	if (hit and (hit.Anchored == false or hit.CanCollide == true)) or self.t > 10 then
		-- so this wont collide with anchored non cancollide things
		if hit then
			Messages:send("OnProjectileHit", self.model.Name, hit, pos, self.owner)
		end
		self:destroy()
	else
		local hit= self:anyNearbyPeople(pos, checkRange)
		if hit then
			Messages:send("OnProjectileHit", self.model.Name, hit, pos, self.owner)
			self:destroy()
		else
			self.model:SetPrimaryPartCFrame(self.model.PrimaryPart.CFrame * CFrame.new(0,-(t^1.2), -speed))
		end
	end
end

function Projectile:destroy()
	if self.destroyed then
		return
	else
		self.destroyed = true
	end
	Messages:send("RemoveProjectile", self.id, self.model.Base.Position)
	self.model:Destroy()
end

function Projectile:spawn(pos, goal, model)
	self.model = model:Clone()
	self.model.Parent = workspace
	self.model.PrimaryPart = self.model.Base
	self.model:SetPrimaryPartCFrame(CFrame.new(pos, goal))
	local trail = self.model:FindFirstChild("Trail", true)
	if trail then trail.Enabled = true end
	for _, p in pairs(self.model:GetChildren()) do
		if p:IsA("BasePart") then
			p.Anchored = true
		end
	end
	self:ignore(self.model)
end

function Projectile:ignore(object)
	if type(object) == "table" then
		for _, v in pairs(object) do
			table.insert(self.ignored, v)
		end
	else
		table.insert(self.ignored, object)
	end
end

function Projectile.new(id)
	local self = {}
	self.id = id
	self.ignored = {}
	setmetatable(self, Projectile)

	return self
end

return Projectile
