local Grab = {}
Grab.__index = Grab

function Grab:instance(tool)
	self.player = tool.Parent.Parent
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
end

function Grab:equipped(character)

end

function Grab:unequipped(character)

end

function Grab.new()
	local tool = {}
	return setmetatable(tool, Grab)
end

return Grab
