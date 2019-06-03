local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local CollectionService = game:GetService("CollectionService")

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
	--[[CollectionService:GetInstanceAddedSignal("Building"):connect(function(boat)
		if CollectionService:HasTag(boat, "Boat") then
			local seat = boat.VehicleSeat
			local signal = seat:GetPropertyChangedSignal("Occupant")
			signal:connect(function()
				local occupant = seat.Occupant
				if occupant then
					local character = occupant.Parent
					--local player = game.Players:GetPlayerFromCharacter(character)
					if player then
						seat:SetNetworkOwner(player)
					end
				end
			end)
		end
	end)--]]
	game:GetService("RunService").Heartbeat:connect(function()
		for _, boat in pairs(CollectionService:GetTagged("Boat")) do
			local  seat = boat:FindFirstChild("VehicleSeat")
			if seat then
				if seat.Occupant then
					--[[local occupant = seat.Occupant
					local character = occupant.Parent
					local player = game.Players:GetPlayerFromCharacter(character)
					if player then
						seat:SetNetworkOwner(player)
					end--]]
					steerBoat(boat, seat)
				end
			end
		end
	end)
end

return Boats
