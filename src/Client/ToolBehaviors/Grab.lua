local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local Grab = {}
Grab.__index = Grab

function Grab:instance(tool)
	self.player = game.Players.LocalPlayer
	self.carryObject = nil
	self.tool = tool
	tool.Equipped:connect(function()
		self:equipped(self.player.Character)
	end)
	tool.Unequipped:connect(function()
		self:unequipped(self.player.Character)
	end)
	tool.Activated:connect(function()
		self:activated()
	end)
	tool.Deactivated:connect(function()
		self:deactivated()
	end)
	self.lastFire = time()
	game:GetService("RunService").RenderStepped:connect(function()
		if self.carryObject then
			local character = self.player.Character
			if character then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root and self.carryObject.Base:FindFirstChild("CarryPos") then
					local mouse = self.player:GetMouse()
					local mag = (mouse.Hit.p - root.Position).magnitude/3
					local dist = math.min(mag, 6)
					self.carryObject.Base.CarryPos.Position = (CFrame.new(root.Position, mouse.Hit.p) * CFrame.new(0,0,-dist)).p
				end
			end
		end
	end)
end

function Grab:activated()
	if self.carryObject then
		Messages:sendServer("ReleaseObject", self.carryObject)
		self.carryObject = nil
		self.tool.Handle.BrickColor = BrickColor.new("Salmon")
	else
		local mouse = self.player:GetMouse()
		local target = mouse.Target
		if target then
			local object = target.Parent
			if object.Parent == workspace and CollectionService:HasTag(object, "Carryable") then
				Messages:sendServer("CarryObject", object)
				self.carryObject = object
				self.tool.Handle.BrickColor = BrickColor.new("Bright green")
			end
		end
	end
end

function Grab:deactivated()

end

function Grab:equipped(character)

end

function Grab:unequipped(character)
	if self.carryObject then
		Messages:sendServer("ReleaseObject", self.carryObject)
		self.carryObject = nil
	end
end

function Grab.new()
	local tool = {}
	return setmetatable(tool, Grab)
end

return Grab
