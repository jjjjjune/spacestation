local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local Medigun = {}
Medigun.__index = Medigun

function Medigun:instance(tool)
	self.player = game.Players.LocalPlayer
	self.carryObject = nil
	self.tool = tool
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
	tool.Activated:connect(function()
		self.down = true
		self:activated()
	end)
	tool.Deactivated:connect(function()
		self.down = false
		self:deactivated()
	end)
	self.lastFire = time()
	game:GetService("RunService").Heartbeat:connect(function()
		if self.down then
			local mouse = self.player:GetMouse()
			local target = mouse.Target
			if target then
				local object = target.Parent
				self.tool.Barrel.Attachment0.WorldPosition = mouse.Hit.p
				if object:FindFirstChild("Humanoid") then
					local character = self.player.Character
					local rp = character.PrimaryPart
					if rp then
						if (mouse.Hit.p - rp.Position).magnitude < 15 then
							Messages:sendServer("HealCharacter", object)
							--self.tool.Barrel.Attachment0.WorldPosition = rp.Position
						end
					end
				end
			end
		else
			self.tool.Barrel.Attachment0.Position = Vector3.new(0,0,0)
			self.tool.Barrel.Attachment1.Position = Vector3.new(0,0,0)
		end
	end)
end

function Medigun:canWaterPlant()
	if self.tool.Amount.Value < self.tool.Amount.MaxValue then
		return true
	else
		return false
	end
end

function Medigun:isFull()
	if self.tool.Amount.Value < self.tool.Amount.MaxValue then
		return false
	else
		return true
	end
end

function Medigun:isEmpty()
	return self.tool.Amount.Value == 0
end

function Medigun:activated()
	local mouse = self.player:GetMouse()
	local target = mouse.Target
	if target then
		local object = target.Parent
		local root = self.tool.Handle
		if (root.Position - mouse.Hit.p).magnitude > 15 then
			return
		end
		if object.Parent == workspace and CollectionService:HasTag(object, "GooHolder") then
			if not self:isFull() then
				Messages:sendServer("FillMedigun", object)
			else
				Messages:send("Notify", "Already full!")
			end
		elseif object.Parent == workspace and object:FindFirstChild("Humanoid") then
			if not self:isEmpty() then
				Messages:sendServer("PutoutFire", object)
			else
				Messages:send("Notify", "Empty! Needs goo!")
			end
		end
	end
end

function Medigun:deactivated()

end

function Medigun:equipped(character)

end

function Medigun:unequipped(character)
	if self.carryObject then
		Messages:sendServer("ReleaseObject", self.carryObject)
		self.carryObject = nil
	end
end

function Medigun.new()
	local tool = {}
	return setmetatable(tool, Medigun)
end

return Medigun
