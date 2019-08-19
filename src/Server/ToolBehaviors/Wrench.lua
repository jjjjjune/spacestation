local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local LowerHealth = import "Shared/Utils/LowerHealth"
local GetNearestTagToPosition = import "Shared/Utils/GetNearestTagToPosition"

local nearbyMachine = function(pos)
	return GetNearestTagToPosition("Machine", pos, 10)
end

local nearEngine = function(start, range)
	local vec1 = (start + Vector3.new(-range,-(range),-range))
	local vec2 = (start + Vector3.new(range,(range),range))
	local region = Region3.new(vec1, vec2)
	local parts = workspace:FindPartsInRegion3(region,nil, 10000)
	for _, part in pairs(parts) do
		if CollectionService:HasTag(part.Parent, "Engine") then
			return true
		end
	end
end


local DAMAGE = 8

local Wrench = {}
Wrench.__index = Wrench

function Wrench:anyNearbyPeople(start, range)
	local vec1 = (start + Vector3.new(-range,-(range),-range))
	local vec2 = (start + Vector3.new(range,(range),range))
	local region = Region3.new(vec1, vec2)
	local parts = workspace:FindPartsInRegion3(region,nil, 10000)
	for _, part in pairs(parts) do
		local humanoid = part.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local canReturn = true
			for _, ignore in pairs(self.player.Character:GetChildren()) do
				if part:IsDescendantOf(ignore) or part == ignore then
					canReturn = false
				end
			end
			if canReturn then
				return part
			end
		end
	end
end

function Wrench:instance(tool)
	self.player = tool.Parent.Parent
	self.lastSwing = time()
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
	tool.Activated:connect(function()
		self:activated()
	end)
end

function Wrench:activated()
	if time() - self.lastSwing < .5 then
		return
	else
		self.lastSwing = time()
	end
	local character = self.player.Character
	local root = character.HumanoidRootPart
	local r = Ray.new(root.Position, root.CFrame.lookVector * 5)
	local hit, pos = workspace:FindPartOnRay(r, character)
	if hit then
		Messages:send("PlayParticle", "Sparks", 10, pos)
	end
	local machine = nearbyMachine(pos)
	if machine and CollectionService:HasTag(machine, "Machine") and CollectionService:HasTag(machine, "Broken") then
		Messages:send("PlaySound", "GoodCraft" ,character.Head.Position)
		Messages:send("RepairMachine", machine, self.player)
	end
	local part = self:anyNearbyPeople(character.Head.Position, 5)
	if part then
		local person = part.Parent
		LowerHealth(self.player, person, DAMAGE)
		--Messages:send("Knockback", person, character.HumanoidRootPart.CFrame.lookVector*20,.4)
		Messages:send("PlaySound", "DamagedLight" ,character.Head.Position)
		Messages:send("PlayParticle", "Sparks", 10, part.Position)
	end
	if nearEngine(pos, 10) then
		Messages:send("HealEngine", math.random(10, 20))
	end
end

function Wrench:equipped(character)

end

function Wrench:unequipped(character)

end

function Wrench.new()
	local tool = {}
	return setmetatable(tool, Wrench)
end

return Wrench
