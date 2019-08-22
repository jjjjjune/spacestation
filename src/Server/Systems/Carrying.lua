local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

local function unanchor(model)
	for _, p in pairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			p.Anchored = false
		end
	end
end

local Carrying = {}

function Carrying:start()
	Messages:hook("CarryObject", function(player, object)
		if object.Parent == workspace then
			if object.Base:FindFirstChild("VehicleWeld") then
				object.Base.VehicleWeld:Destroy()
			end
			unanchor(object)
			object.Parent = player.Character
			object.Base:SetNetworkOwner(player)
			for _, p in pairs(object:GetChildren()) do
				if p:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(p, "Fake")
				end
			end
			local carryPos = Instance.new("BodyPosition", object.Base)
			carryPos.Name = "CarryPos"
			carryPos.D = 500
			carryPos.P = 20000
			carryPos.Position = object.Base.Position
			carryPos.MaxForce = Vector3.new(200000,200000,200000)
			local carryGyro = Instance.new("BodyGyro", object.Base)
			carryGyro.Name = "CarryGyro"
			local beam = game.ReplicatedStorage.Assets.Particles.Beam:Clone()
			beam.Parent = object.Base
			local attach1 = Instance.new("Attachment", object.Base)
			attach1.Name = "Attach1"
			beam.Attachment0 = attach1
			local attach2 = Instance.new("Attachment", object.Base)
			beam.Attachment1 = attach2
			attach2.Name = "Attach2"
			attach2.Parent = player.Character["RightHand"]
			Messages:send("PlaySound", "ErrorLight", attach2.WorldPosition)
		end
	end)
	Messages:hook("ReleaseObject", function(player, object)
		if object.Parent == player.Character then
			object.Parent = workspace
			for _, p in pairs(object:GetChildren()) do
				if p:IsA("BasePart") then
					PhysicsService:SetPartCollisionGroup(p, "Default")
				end
			end
			object.Base.CarryGyro:Destroy()
			object.Base.CarryPos:Destroy()
			object.Base.Beam:Destroy()
			object.Base.Attach1:Destroy()
			player.Character["RightHand"].Attach2:Destroy()
			Messages:send("PlaySound", "ErrorLight", object.Base.Position)
			Messages:send("OnObjectReleased", player, object)
		end
	end)
end

return Carrying
