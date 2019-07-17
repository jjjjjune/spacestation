local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local PathfindingService = game:GetService("PathfindingService")
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")

local lastPaths = {}
local lastCanBreathe = {}
local lastGoodPoints = {}
local outParticles = {}

PhysicsService:CreateCollisionGroup("Fake")
PhysicsService:CollisionGroupSetCollidable("Fake", "Default", false)

local function nearbyOxygenTank()
	for i, v in pairs(game.Workspace.Tanks:GetChildren()) do
		if (v.Position - player.Character.Head.Position).magnitude < 50 then
			if v.Amount.Value > 0 then
				v.Value = v.Value - 1
				return true
			else
				return false
			end
		end
	end
	return true
end

local function canBreathe(player)
	if not lastPaths[player] then
		lastPaths[player] = time() - 100
	end
	if time() - lastPaths[player] > .6 then
		lastPaths[player] = time()
		local start = player.Character.HumanoidRootPart.Position + Vector3.new(0,1,0)
		local goal = start + Vector3.new(0,0,400)

		local part = Instance.new("Part", workspace)
		part.Anchored = true
		part.Size = Vector3.new(100,1,(start-goal).magnitude + 40)
		part.CFrame = CFrame.new(start, goal) * CFrame.new(0, -4, -part.Size.Z/2)
		part.Transparency = 1
		PhysicsService:SetPartCollisionGroup(part, "Fake")
		game:GetService("Debris"):AddItem(part,1)

		local result = PathfindingService:ComputeRawPathAsync(start, goal, 800)
		if result.Status == Enum.PathStatus.Success then
			lastCanBreathe[player] = false
			return false
		else
			if player.Character  then
				if outParticles[player] then
					outParticles[player]:Destroy()
					outParticles[player] = nil
				end
				lastGoodPoints[player] = player.Character.HumanoidRootPart.Position
				lastCanBreathe[player] = true
			end
			return true
		end
	else
		return lastCanBreathe[player]
	end
end

local Oxygen = {}

function Oxygen:start()
	spawn(function()
		while wait(.25) do
			for _, player in pairs(game.Players:GetPlayers()) do
				if player.Character then
					if canBreathe(player) then
						CollectionService:AddTag(player.Character,"Breathing")
					else
						CollectionService:RemoveTag(player.Character,"Breathing")
						player.Character.Humanoid:TakeDamage(1)
					end
				end
			end
		end
	end)
	game.Players.PlayerRemoving:connect(function(player)
		if outParticles[player] then
			outParticles[player]:Destroy()
			outParticles[player] = nil
		end
	end)
end

return Oxygen
