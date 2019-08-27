local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Handcuffs = {}
Handcuffs.__index = Handcuffs

function Handcuffs:instance(tool)
	self.player = tool.Parent.Parent
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

function Handcuffs:activated()
	local mouse = self.player:GetMouse()
	local target = mouse.Target
	if target then
		local char = target.Parent
		local player = game.Players:GetPlayerFromCharacter(char)
		if player then
			if (mouse.Hit.p - self.player.PrimaryPart.Position).magnitude < 10 then
				Messages:sendServer("AttemptArrest", player)
			end
		end
	end
end

function Handcuffs:equipped(character)

end

function Handcuffs:unequipped(character)

end

function Handcuffs.new()
	local tool = {}
	return setmetatable(tool, Handcuffs)
end

return Handcuffs
