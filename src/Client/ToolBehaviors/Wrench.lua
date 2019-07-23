local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local HttpService = game:GetService("HttpService")

local Wrench = {}
Wrench.__index = Wrench

function Wrench:instance(tool)
	self.lastSwing = time()
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

function Wrench:activated()
	local pos = self.player.Character.PrimaryPart.Position
	Messages:sendServer("PlaySoundServer", "HeavyWhoosh", pos)
	Messages:send("PlayAnimationClient", "Swing4")
end

function Wrench:equipped(character)

end

function Wrench:unequipped(character)

end

function Wrench.new()
	local tool = {}
	return setmetatable(tool, Wrench)
end

return Wrench
