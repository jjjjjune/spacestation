local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local Wrench = {}
Wrench.__index = Wrench

function Wrench:instance(tool)
	self.player = tool.Parent.Parent
	self.lastSwing = time()
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
	tool.Activated:connect(function()
		self:activated()
	end)
end

function Wrench:activated()
	if time() - self.lastSwing < .5 then
		return
	else
		self.lastSwing = time()
	end
	local root = self.player.Character.HumanoidRootPart
	local r = Ray.new(root.Position, root.CFrame.lookVector * 5)
	local hit, pos = workspace:FindPartOnRay(r, self.player.Character)
	if hit then
		Messages:send("PlayParticle", "Sparks", 10, pos)
	end
	if hit and CollectionService:HasTag(hit.Parent, "Machine") and CollectionService:HasTag(hit.Parent, "Broken") then
		Messages:send("PlaySound", "GoodCraft" ,self.player.Character.Head.Position)
		Messages:send("RepairMachine", hit.Parent, self.player)
	elseif hit then
		Messages:send("PlaySound", "DamagedLight" ,self.player.Character.Head.Position)
	end
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
