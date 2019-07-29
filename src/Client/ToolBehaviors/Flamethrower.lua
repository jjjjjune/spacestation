local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local HttpService = game:GetService("HttpService")

local Flamethrower = {}
Flamethrower.__index = Flamethrower

function Flamethrower:instance(tool)
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

function Flamethrower:activated()

end

function Flamethrower:equipped(character)

end

function Flamethrower:unequipped(character)

end

function Flamethrower.new()
	local tool = {}
	return setmetatable(tool, Flamethrower)
end

return Flamethrower
