local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local Fire = {}
Fire.__index = Fire

function Fire:instance(tool)
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
	tool.RequiresHandle = false
	tool.CanBeDropped = false
end

function Fire:activated()
	local mouse = self.player:GetMouse()
	local r= Ray.new(mouse.UnitRay.Origin, mouse.UnitRay.Direction * 40)
	local target, pos = workspace:FindPartOnRay(r)
	if target and target.Parent:FindFirstChild("Humanoid") then
		local player = game.Players:GetPlayerFromCharacter(target.Parent)
		if player then
			if (mouse.Hit.p - self.player.Character.HumanoidRootPart.Position).magnitude < 30 then
				if player.Team.Name ~= "Workers" then
					Messages:send("OpenYesNoDialogue", {
						text = "Fire "..player.Name.." from their job as "..player.Team.Name.."?",
						yesCallback = function()
							Messages:sendServer("FireFromJob", player)
						end,
					})
				end
			end
		end
	end
end

function Fire:equipped(character)

end

function Fire:unequipped(character)

end

function Fire.new()
	local tool = {}
	return setmetatable(tool, Fire)
end

return Fire
