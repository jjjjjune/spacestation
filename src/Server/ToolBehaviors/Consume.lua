local Consume = {}
Consume.__index = Consume

function Consume:instance(tool)
	self.player = tool.Parent.Parent
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
	tool.RequiresHandle = false
	tool.CanBeDropped = false
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
