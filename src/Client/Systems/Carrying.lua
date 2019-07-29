local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'

local CollectionService = game:GetService("CollectionService")
local MAX_DISTANCE = 10

local box = Instance.new("SelectionBox")

local player = game.Players.LocalPlayer

local function getClosestCarryable(position)
	local closestDist = MAX_DISTANCE
	local closestDrawer = nil
	for _, drawer in pairs(CollectionService:GetTagged("Carryable")) do
		local dist = (drawer.Base.Position - position).magnitude
		if dist < closestDist then
			closestDrawer = drawer
			closestDist = dist
		end
	end
	return closestDrawer
end

local Carrying = {}

function Carrying:start()
	game:GetService("RunService").Stepped:connect(function()
		if player.Character then
			if player.Character:FindFirstChild("HumanoidRootPart") then
				local pos = player.Character.HumanoidRootPart.Position
				local carryable = getClosestCarryable(pos)
				if carryable and carryable.Parent == workspace and player.Character:FindFirstChild("Grab") then
					--box.Parent = carryable
					--box.Adornee = carryable
				else
					box.Parent = nil
					box.Adornee = nil
				end
			end
		end
	end)
end

return Carrying
