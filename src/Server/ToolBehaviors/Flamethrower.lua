local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Flamethrower = {}
Flamethrower.__index = Flamethrower

function Flamethrower:instance(tool)
	self.player = tool.Parent.Parent
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
	tool.Activated:connect(function()
		self:activated(self.player.Character)
	end)
	tool.Deactivated:connect(function()
		self:deactivated(self.player.Character)
	end)
	tool.RequiresHandle = false
	tool.CanBeDropped = false
	self.tool = tool
end

function Flamethrower:activated(character)
	self.tool.Barrel.Attachment.Fire.Rate = 30
	self.tool.HeatArea.Temperature.Value = 1000
	self.tool.HeatArea.HeaterSound:Play()
	Messages:send("ForceStep")
	self.isActivated = true
end

function Flamethrower:deactivated(character)
	self.tool.Barrel.Attachment.Fire.Rate = 0
	self.tool.HeatArea.Temperature.Value = 90
	self.tool.HeatArea.HeaterSound:Stop()
	self.isActivated = false
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
