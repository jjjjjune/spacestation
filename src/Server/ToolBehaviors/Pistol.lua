local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local HttpService = game:GetService("HttpService")

local Pistol = {}
Pistol.__index = Pistol

function Pistol:instance(tool)
	self.player = tool.Parent.Parent
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
	tool.Activated:connect(function(mouse)
		self:activated(mouse)
	end)
end

function Pistol:activated(mouse)

end

function Pistol:equipped(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	Messages:sendClient(player, "SetTool", "Pistol")
end

function Pistol:unequipped(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	Messages:sendClient(player, "SetTool", nil)
end

function Pistol.new()
	local tool = {}
	return setmetatable(tool, Pistol)
end

return Pistol
