local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local PlayerData = import "Shared/PlayerData"
local RunService = game:GetService("RunService")

local VEHICLE_DESPAWN_TIME = 300
local BUILT_ON_VEHICLE_DESPAWN_TIME = 660

local lastWasInVehicle = {}
local currentVehicles = {}

local function buyVehicle(player, shop)
	local unlocks = PlayerData:get(player, "unlocks")
	local cash = PlayerData:get(player, "cash")
	if shop:FindFirstChild("UnlockPrice") then
		if not unlocks[shop.Vehicle.Value] then
			local price = shop.UnlockPrice.Value
			if cash >= price then
				unlocks[shop.Vehicle.Value] = true
				PlayerData:set(player, "unlocks", unlocks)
				PlayerData:add(player, "cash", -price)
				Messages:send("PlaySound", "Chime", shop.Base.Position)
			else
				Messages:send("PlaySound", "Error", shop.Base.Position)
			end
		end
	end
end

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
				if not currentVehicles[player] then
					currentVehicles[player] = {}
				end
				currentVehicles[player][vehicle.Name] = vehicle
			end
			lastWasInVehicle[vehicle] = time()
		else
			vehicle.Base.BodyPosition.MaxForce = Vector3.new(0,0,0)
			vehicle.Base.ShipEngine:Stop()
			lastWasInVehicle[vehicle] = time()
			spawn(function()
				wait(.1)
				vehicle.Base.BodyPosition.MaxForce = Vector3.new(0,0,0)
			end)
		end
	end)
	lastWasInVehicle[vehicle] = time()
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
	previewModel.Name = "Preview"
	previewModel.VehicleSeat:Destroy()
	previewModel:SetPrimaryPartCFrame(spawn.Base.CFrame * CFrame.new(0,2,0))
	CollectionService:RemoveTag(previewModel, "Vehicle")
	previewModel.Parent =spawn
	for _, v in pairs(previewModel:GetChildren()) do
		if v:IsA("BasePart") then
			v.Anchored = true
			if v.Transparency == 0 then
				v.Transparency = .7
			end
			--v.BrickColor = BrickColor.new("Teal")
			--v.Material = Enum.Material.Neon
			v.CanCollide = false
		end
	end
	Messages:send("RegisterDetector", spawn.Button.ClickDetector, function(player)
		if spawn:FindFirstChild("UnlockPrice") then
			local unlocks = PlayerData:get(player, "unlocks")
			if not unlocks[spawn.Vehicle.Value] then
				Messages:sendClient(player, "OpenVehicleBuyDialog", spawn)
				return
			else
				Messages:send("PlaySound", "Chime", spawn.Base.Position)
			end
		end
		if not currentVehicles[player] then
			currentVehicles[player] = {}
		end
		local vehicleModel =game.ReplicatedStorage.Assets.Vehicles[vehicle]:Clone()
		if not currentVehicles[player][vehicleModel.Name] then
			currentVehicles[player][vehicleModel.Name] = vehicleModel
		else
			if currentVehicles[player][vehicleModel.Name].Parent == workspace then
				Messages:sendClient(player, "Notify", "You already have a vehicle of this type spawned!")
				return
			else
				currentVehicles[player][vehicleModel.Name] = vehicleModel
			end
		end
		vehicleModel.Parent = workspace
		vehicleModel:SetPrimaryPartCFrame(spawn.Base.CFrame * CFrame.new(0,2,0))
	end)
end

local function checkVehicleDespawn()
	for vehicle, t in pairs(lastWasInVehicle) do
		if vehicle:FindFirstChild("VehicleSeat") then
			if vehicle.VehicleSeat.Occupant ~= nil then
				lastWasInVehicle[vehicle] = time()
			else
				local threshold = VEHICLE_DESPAWN_TIME
				local parts = vehicle.Base:GetConnectedParts(true)
				for _, p in pairs(parts) do
					if not p:IsDescendantOf(vehicle) then
						threshold = BUILT_ON_VEHICLE_DESPAWN_TIME
					end
				end
				if time() - t > threshold then
					vehicle:Destroy()
					lastWasInVehicle[vehicle] = nil
				end
			end
		else
			lastWasInVehicle[vehicle] = nil
		end
	end
end

local Vehicles = {}

function Vehicles:start()
	for _, vehicle in pairs(CollectionService:GetTagged("Vehicle")) do
		if vehicle:IsDescendantOf(workspace) then
			initializeVehicle(vehicle)
		end
	end
	CollectionService:GetInstanceAddedSignal("Vehicle"):connect(function(vehicle)
		initializeVehicle(vehicle)
	end)
	RunService.Stepped:connect(function()
		adjustVehicleVolumes()
		checkVehicleDespawn()
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
	Messages:hook("BuyVehicle", function(player, vehicle)
		buyVehicle(player, vehicle)
	end)
	for _, spawn in pairs(CollectionService:GetTagged("VehicleSpawn")) do
		setupVehicleSpawn(spawn)
	end
end

return Vehicles
