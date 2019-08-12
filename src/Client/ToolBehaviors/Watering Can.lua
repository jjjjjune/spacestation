local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")

local WateringCan = {}
WateringCan.__index = WateringCan

function WateringCan:instance(tool)
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

function WateringCan:canWaterPlant()
	if CollectionService:HasTag(self.tool, "Full") then
		return true
	else
		return false
	end
end

function WateringCan:activated()
	local mouse = self.player:GetMouse()
	local target = mouse.Target
	if target then
		local object = target.Parent
		local root = self.tool.Handle
		if (root.Position - mouse.Hit.p).magnitude > 15 then
			return
		end
		if object.Parent == workspace and CollectionService:HasTag(object, "Well") then
			if not self:canWaterPlant() then
				print('filling')
				Messages:sendServer("FillWateringCan", object)
			else
				Messages:send("Notify", "Already full!")
			end
		elseif object.Parent == workspace and CollectionService:HasTag(object, "Plant") then
			local object = target.Parent
			local root = self.tool.Handle
			if (root.Position - mouse.Hit.p).magnitude > 15 then
				return
			end
			if self:canWaterPlant() then
				Messages:sendServer("WaterPlant", object)
			else
				Messages:send("Notify", "Watering can empty!")
			end
		elseif object.Parent == workspace and CollectionService:HasTag(object, "Burning") then
			if self:canWaterPlant() then
				Messages:sendServer("PutoutFire", object)
			else
				Messages:send("Notify", "Watering can empty!")
			end
		end
	end
end

function WateringCan:deactivated()

end

function WateringCan:equipped(character)

end

function WateringCan:unequipped(character)
	if self.carryObject then
		Messages:sendServer("ReleaseObject", self.carryObject)
		self.carryObject = nil
	end
end

function WateringCan.new()
	local tool = {}
	return setmetatable(tool, WateringCan)
end

return WateringCan
