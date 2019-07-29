local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Eat = {}
Eat.__index = Eat

function Eat:instance(tool)
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

function Eat:activated()
	local mouse = self.player:GetMouse()
	local r= Ray.new(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 40)
	local target, pos = workspace:FindPartOnRay(r)
	if target and target.Parent:FindFirstChild("Humanoid") then
		if (mouse.Hit.p - self.player.Character.HumanoidRootPart.Position).magnitude < 10 then
			Messages:sendServer("EatPlayerPart", target)
		end
	end
end

function Eat:equipped(character)

end

function Eat:unequipped(character)

end

function Eat.new()
	local tool = {}
	return setmetatable(tool, Eat)
end

return Eat
