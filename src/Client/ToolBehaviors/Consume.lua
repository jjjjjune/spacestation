local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Consume = {}
Consume.__index = Consume

function Consume:instance(tool)
	self.player = game.Players.LocalPlayer
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
	tool.Activated:connect(function()
		self:activated()
	end)
	tool.RequiresHandle = false
	tool.CanBeDropped = false
end

function Consume:activated()
	print("activated")
	local mouse = self.player:GetMouse()
	local target = mouse.Target
	if target and target.Parent:FindFirstChild("Humanoid") then
		print("yeet")
		if (mouse.Hit.p - self.player.Character.HumanoidRootPart.Position).magnitude < 10 then
			print("ok server")
			Messages:sendServer("ConsumePlayerPart", target)
		end
	end
end

function Consume:equipped(character)

end

function Consume:unequipped(character)

end

function Consume.new()
	local tool = {}
	return setmetatable(tool, Consume)
end

return Consume
