local WateringCan = {}
WateringCan.__index = WateringCan

function WateringCan:instance(tool)
	self.player = tool.Parent.Parent
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
end

function WateringCan:equipped(character)

end

function WateringCan:unequipped(character)

end

function WateringCan.new()
	local tool = {}
	return setmetatable(tool, WateringCan)
end

return WateringCan
