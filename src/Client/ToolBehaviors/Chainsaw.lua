local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local HttpService = game:GetService("HttpService")

local Chainsaw = {}
Chainsaw.__index = Chainsaw

function Chainsaw:instance(tool)
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

function Chainsaw:activated()
	if not self.lastSwing then
		self.lastSwing = time()
	else
		if time() - self.lastSwing < .5 then
			return
		else
			self.lastSwing = time()
		end
	end
	local pos = self.player.Character.PrimaryPart.Position
	Messages:sendServer("PlaySoundServer", "HeavyWhoosh", pos)
	Messages:send("PlayAnimationClient", "Swing4")
end

function Chainsaw:equipped(character)

end

function Chainsaw:unequipped(character)

end

function Chainsaw.new()
	local tool = {}
	return setmetatable(tool, Chainsaw)
end

return Chainsaw
