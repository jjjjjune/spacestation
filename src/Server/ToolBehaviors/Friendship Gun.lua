local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local HttpService = game:GetService("HttpService")

local FriendshipGun = {}
FriendshipGun.__index = FriendshipGun

function FriendshipGun:instance(tool)
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

function FriendshipGun:activated(mouse)

end

function FriendshipGun:equipped(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	Messages:sendClient(player, "SetTool", "FriendshipGun")
end

function FriendshipGun:unequipped(character)
	local player = game.Players:GetPlayerFromCharacter(character)
	Messages:sendClient(player, "SetTool", nil)
end

function FriendshipGun.new()
	local tool = {}
	return setmetatable(tool, FriendshipGun)
end

return FriendshipGun
