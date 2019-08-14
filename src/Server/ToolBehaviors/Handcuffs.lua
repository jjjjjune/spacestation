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
	tool.RequiresHandle = false
	tool.CanBeDropped = false
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
