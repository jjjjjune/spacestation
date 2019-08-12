local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Keycard = {}
Keycard.__index = Keycard

function Keycard:instance(tool)
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

function Keycard:activated()
end

function Keycard:equipped(character)

end

function Keycard:unequipped(character)

end

function Keycard.new()
	local tool = {}
	return setmetatable(tool, Keycard)
end

return Keycard
