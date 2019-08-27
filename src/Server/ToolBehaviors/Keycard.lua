local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local Keycard = {}
Keycard.__index = Keycard

function Keycard:instance(tool)
	self.player = tool.Parent.Parent
	tool.Indicator.BrickColor = self.player.TeamColor
	--[[local teamValue = Instance.new("StringValue", tool)
	teamValue.Name = "Team"
	teamValue.Value = self.player.Team.Name--]]
	tool.Handle.Touched:connect(function(hit)
		local door = hit.Parent
		if CollectionService:HasTag(door, "Door") then
			if door.OpenValue.Value == false then
				Messages:send("UnlockDoor", door, tool)
			end
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

function Keycard:equipped(character)

end

function Keycard:unequipped(character)

end

function Keycard.new()
	local tool = {}
	return setmetatable(tool, Keycard)
end

return Keycard
