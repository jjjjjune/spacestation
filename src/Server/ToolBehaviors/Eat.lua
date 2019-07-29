local Eat = {}
Eat.__index = Eat

function Eat:instance(tool)
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

function Eat:equipped(character)

end

function Eat:unequipped(character)

end

function Eat.new()
	local tool = {}
	return setmetatable(tool, Eat)
end

return Eat
