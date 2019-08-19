local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local HttpService = game:GetService("HttpService")

local FriendshipGun = {}
FriendshipGun.__index = FriendshipGun

function FriendshipGun:instance(tool)
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

function FriendshipGun:activated()
	if not self.lastFire then
		self.lastFire = time()
	else
		if time() - self.lastFire > .5 then
			self.lastFire = time()
		else
			return
		end
	end
	Messages:send("PlayAnimationClient", "Shoot")
	local mouse = game.Players.LocalPlayer:GetMouse()
	local target = mouse.Hit.p
	local start = self.player.Character:FindFirstChildOfClass("Tool").Handle.Position
	local id = HttpService:GenerateGUID()
	local model = game.ReplicatedStorage.Assets.Projectiles["Friend Bullet"]
	Messages:sendServer("CreateProjectileServer",id, start, target, model, self.player.Character)
	Messages:send("CreateProjectile",id, start, target, model.Name)
	Messages:sendServer("PlaySoundServer", "Laser", start)
	Messages:sendServer("PlayParticleServer", "Sparks", 10, start)
end

function FriendshipGun:equipped(character)

end

function FriendshipGun:unequipped(character)

end

function FriendshipGun.new()
	local tool = {}
	return setmetatable(tool, FriendshipGun)
end

return FriendshipGun
