local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local function initializeVehicle(vehicle)
	vehicle.VehicleSeat:GetPropertyChangedSignal("Occupant"):connect(function()
		local newOccupantHumanoid = vehicle.VehicleSeat.Occupant
		if newOccupantHumanoid then
			vehicle.Base.ShipEngine:Play()
			local character = newOccupantHumanoid.Parent
			local player = game.Players:GetPlayerFromCharacter(character)
			if player then
				vehicle.Base:SetNetworkOwner(player)
				Messages:sendClient(player, "ClaimVehicle", vehicle)
			end
		else
			vehicle.Base.ShipEngine:Stop()
		end
	end)

end

local function adjustVehicleVolumes()
	for _, vehicle in pairs(CollectionService:GetTagged("Vehicle")) do
		local mag = vehicle.VehicleSeat.Velocity.magnitude
		vehicle.Base.ShipEngine.PlaybackSpeed = .6 + (mag/200)
	end
end

local function setupVehicleSpawn(spawn)
	local vehicle = spawn.Vehicle.Value
	local previewModel = game.ReplicatedStorage.Assets.Vehicles[vehicle]:Clone()
	previewModel.VehicleSeat:Destroy()
	previewModel:SetPrimaryPartCFrame(spawn.Base.CFrame * CFrame.new(0,2,0))
	previewModel.Parent = workspace
	CollectionService:RemoveTag(previewModel, "Vehicle")
	for _, v in pairs(previewModel:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = true
			if v.Transparency == 0 then
				v.Transparency = .5
			end
			v.BrickColor = BrickColor.new("Teal")
			v.Material = Enum.Material.Neon
		end
	end
end

local Vehicles = {}

function Vehicles:start()
	for _, vehicle in pairs(CollectionService:GetTagged("Vehicle")) do
		initializeVehicle(vehicle)
	end
	CollectionService:GetInstanceAddedSignal("Vehicle"):connect(function(vehicle)
		initializeVehicle(vehicle)
	end)
	RunService.Stepped:connect(function()
		adjustVehicleVolumes()
	end)
	Messages:hook("DestroyVehicle", function(vehicle)
		vehicle:BreakJoints()
		for _, v in pairs(vehicle:GetChildren()) do
			if v:IsA("BasePart") then
				v.BrickColor = BrickColor.new("Black")
			end
		end
		game:GetService("Debris"):AddItem(vehicle, 5)
	end)
	for _, spawn in pairs(CollectionService:GetTagged("VehicleSpawn")) do
		setupVehicleSpawn(spawn)
	end
end

return Vehicles
