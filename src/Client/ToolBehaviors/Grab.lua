local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local Grab = {}
Grab.__index = Grab

function Grab:instance(tool)
	self.player = game.Players.LocalPlayer
	self.carryObject = nil
	self.tool = tool
	self.wasThrowDown = false
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
		local mouse = self.player:GetMouse()
		if mouse.Target and mouse.Target.Name == "HeatArea" then
			mouse.TargetFilter = mouse.Target
		end
		if self.carryObject then
			local character = self.player.Character
			if character then
				local root = character:FindFirstChild("HumanoidRootPart")
				if root and self.carryObject.Base:FindFirstChild("CarryPos") then
					local mag = (mouse.Hit.p - root.Position).magnitude
					local dist = math.min(mag, 12)
					if UserInputService.TouchEnabled then
						self.carryObject.Base.CarryPos.Position = (root.CFrame * CFrame.new(0,0,-dist)).p
					else
						local startCF = CFrame.new(root.Position, mouse.Hit.p) * CFrame.new(0,0,-3)
						self.carryObject.Base.CarryPos.Position = (startCF* CFrame.new(0,0,-dist)).p
					end
				end
			end
		end
	end)
end

function Grab:activated()
	if self.carryObject then
		Messages:sendServer("ReleaseObject", self.carryObject)
		self.carryObject.Base.CarryPos:Destroy()
		self.carryObject.Base.Velocity = self.player.Character.PrimaryPart.Velocity * 5
		self.carryObject = nil
		self.tool.Handle.BrickColor = BrickColor.new("Salmon")
	else
		local mouse = self.player:GetMouse()
		local target = mouse.Target
		if target then
			local object = target.Parent
			if object.Parent == workspace and CollectionService:HasTag(object, "Carryable") then
				local player = game.Players.LocalPlayer
				local dist = (self.player:GetMouse().Hit.p -  player.Character.Head.Position).magnitude
				if dist < 20 then
					Messages:sendServer("CarryObject", object)
					self.carryObject = object
					self.tool.Handle.BrickColor = BrickColor.new("Bright green")
				end
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
