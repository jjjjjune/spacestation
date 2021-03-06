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
PhysicsService:CollisionGroupSetCollidable("Fake", "Fake", false)

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
	local character = player.Character
	if not character then
		return
	end
	local root = character.PrimaryPart
	if not root then
		return
	end
	if time() - lastPaths[player] > .6 then
		lastPaths[player] = time()
		local start = root.Position + Vector3.new(0,1,0)
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
				lastGoodPoints[player] = root.Position
				lastCanBreathe[player] = true
			end
			return true
		end
	else
		return lastCanBreathe[player]
	end
end

local function checkOxygen()
	for _, player in pairs(game.Players:GetPlayers()) do
		if player.Character then
			if canBreathe(player) then
				CollectionService:AddTag(player.Character,"Breathing")
			else
				CollectionService:RemoveTag(player.Character,"Breathing")
				if CollectionService:HasTag(player.Character, "Burning") then
					Messages:send("Extinguish", player.Character)
				end
			end
		end
	end
end

local lastOxygenCheck = time()

local Oxygen = {}

function Oxygen:start()
	game:GetService("RunService").Stepped:connect(function()
		if time() - lastOxygenCheck > .25 then
			lastOxygenCheck = time()
			checkOxygen()
		else
			return
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
