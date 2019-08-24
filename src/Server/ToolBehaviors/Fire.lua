local Fire = {}
Fire.__index = Fire

function Fire:instance(tool)
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

function Fire:equipped(character)

end

function Fire:unequipped(character)

end

function Fire.new()
	local tool = {}
	return setmetatable(tool, Fire)
end

return Fire
