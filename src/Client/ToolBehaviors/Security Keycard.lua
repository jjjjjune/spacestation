local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Flashlight = {}
Flashlight.__index = Flashlight

function Flashlight:instance(tool)
	self.player = game.Players.LocalPlayer
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
	tool.Activated:connect(function()
		self:activated()
	end)
	self.lastFire = time()
end

function Flashlight:activated()
end

function Flashlight:equipped(character)

end

function Flashlight:unequipped(character)

end

function Flashlight.new()
	local tool = {}
	return setmetatable(tool, Flashlight)
end

return Flashlight
