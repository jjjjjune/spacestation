local Scythe = {}
Scythe.__index = Scythe

function Scythe:instance(tool)
	self.player = tool.Parent.Parent
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
end

function Scythe:equipped(character)

end

function Scythe:unequipped(character)

end

function Scythe.new()
	local tool = {}
	return setmetatable(tool, Scythe)
end

return Scythe
