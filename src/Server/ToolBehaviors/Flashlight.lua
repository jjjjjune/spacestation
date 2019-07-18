local Flashlight = {}
Flashlight.__index = Flashlight

function Flashlight:instance(tool)
	print("instance for: ", tool)
	self.player = tool.Parent.Parent
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
end

function Flashlight:equipped(character)
	character.HumanoidRootPart.PointLight.Brightness = 1
end

function Flashlight:unequipped(character)
	character.HumanoidRootPart.PointLight.Brightness = .2
end

function Flashlight.new()
	local tool = {}
	return setmetatable(tool, Flashlight)
end

return Flashlight
