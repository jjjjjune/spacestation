local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

local myBoat = nil

local Boats = {}

local function steerBoat(boat, seat)
	local forward = seat.Throttle
	local side = seat.Steer
	local gyro = boat.Base.BodyGyro
	local force = boat.Base.BodyForce
	gyro.CFrame = gyro.CFrame * CFrame.Angles(0, -math.rad(side),0)
	force.Force = boat.Base.CFrame.lookVector * forward* boat.Speed.Value
end

function Boats:start()
	CollectionService:GetInstanceAddedSignal("Building"):connect(function(boat)
		wait()
		if CollectionService:HasTag(boat, "Boat") then
			boat:WaitForChild("VehicleSeat")
			local seat = boat.VehicleSeat
			local signal = seat:GetPropertyChangedSignal("Occupant")
			signal:connect(function()
				local occupant = seat.Occupant
				if occupant then
					local character = occupant.Parent
					local player = game.Players:GetPlayerFromCharacter(character)
					if player and player == game.Players.LocalPlayer then
						myBoat = boat
					else
						myBoat = nil
					end
				end
			end)
		end
	end)
	game:GetService("RunService").RenderStepped:connect(function()
		if myBoat then
			steerBoat(myBoat, myBoat.VehicleSeat)
		end
	end)
end

return Boats
