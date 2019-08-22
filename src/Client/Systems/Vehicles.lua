local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'

local RunService = game:GetService("RunService")

local player = game.Players.LocalPlayer
local myVehicle
local lastThrottle = 0

local function doSteering(vehicle, seat)
	local speed = seat.MaxSpeed
	local steer = seat.Steer
	local throttle = seat.Throttle
	throttle = math.ceil(throttle)
	if throttle < 1 and math.abs(lastThrottle) > math.abs(throttle)  and lastThrottle ~= 0 then
		throttle = lastThrottle*.95
		lastThrottle = throttle
		if (throttle > 0 and throttle < .1) or  (throttle < 0 and throttle > -.1) then
			throttle = 0
			lastThrottle = 0
		end
	else
		lastThrottle = throttle
	end
	local start = (vehicle.Base.CFrame * CFrame.new(0,0,-vehicle.Base.Size.Z/2)).p
	local r= Ray.new(start, Vector3.new(0,-8,0))
	local hit1, pos1 = workspace:FindPartOnRay(r, vehicle)
	if hit1 then
		vehicle.Base.BodyPosition.MaxForce = Vector3.new(0,100000,0)
		vehicle.Base.BodyPosition.Position = pos1 + Vector3.new(0,2,0)
	end
	local start = (vehicle.Base.CFrame * CFrame.new(0,0,vehicle.Base.Size.Z/2)).p
	local r= Ray.new(start, Vector3.new(0,-8,0))
	local hit2, pos2 = workspace:FindPartOnRay(r, vehicle)
	if hit2 then
		if pos2.Y > pos1.Y then
			vehicle.Base.BodyPosition.MaxForce = Vector3.new(0,100000,0)
			vehicle.Base.BodyPosition.Position = pos2 + Vector3.new(0,2,0)
		end
	end



	local gyro = vehicle.Base.BodyGyro

	local look = gyro.CFrame.LookVector
	local yaw = math.atan2(-look.X, -look.Z)

	local turn = -steer * math.rad(3)
	local roll = steer * math.rad(5)
	local pitch = throttle*math.rad(-5)

	gyro.CFrame = CFrame.Angles(0, yaw + turn, 0) * CFrame.Angles(0, 0, roll) * CFrame.Angles(pitch,0,0)

	local goalVelocity = vehicle.Base.CFrame.lookVector * (throttle*speed)
	vehicle.Base.Velocity = Vector3.new(goalVelocity.X, vehicle.Base.Velocity.Y, goalVelocity.Z)

end

local function vehicleTick()
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			if myVehicle then
				local seat = myVehicle.VehicleSeat
				if seat.Occupant == humanoid then
					doSteering(myVehicle, seat)
				end
			end
		end
	end
end

local Vehicles = {}

function Vehicles:start()
	Messages:hook("ClaimVehicle", function(vehicle)
		myVehicle = vehicle
	end)
	RunService.RenderStepped:connect(function()
		vehicleTick()
	end)
end

return Vehicles
