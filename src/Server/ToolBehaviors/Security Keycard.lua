local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local Flashlight = {}
Flashlight.__index = Flashlight

function Flashlight:instance(tool)
	self.player = tool.Parent.Parent
	tool.Handle.Touched:connect(function(hit)
		local door = hit.Parent
		if CollectionService:HasTag(door, "Door") then
			Messages:send("UnlockDoor", door)
		end
	end)
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)

	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
	tool.Activated:connect(function()

	end)
end

function Flashlight:equipped(character)
	--character.HumanoidRootPart.PointLight.Brightness = 1
end

function Flashlight:unequipped(character)
	--character.HumanoidRootPart.PointLight.Brightness = .2
end

function Flashlight.new()
	local tool = {}
	return setmetatable(tool, Flashlight)
end

return Flashlight
