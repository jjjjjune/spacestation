local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")

local function getRegion(part)
	local xRange = part.Size.X + 4
	local yRange = part.Size.Y + 4
	local zRange = part.Size.Z + 4
	local vec1 = (part.Position + Vector3.new(-xRange,-yRange,-zRange))
	local vec2 = (part.Position + Vector3.new(xRange,yRange,zRange))
	local region = Region3.new(vec1, vec2)
	return region
end

local function getReactableObjects(console)
	local region = getRegion(console.Area)
	local reactable = {}
	local alreadyReacted = {}
	for _, part in pairs(workspace:FindPartsInRegion3(region)) do
		if CollectionService:HasTag(part.Parent, "Carryable") or part.Parent:FindFirstChild("Humanoid") then
			if not alreadyReacted[part.Parent] then
				alreadyReacted[part.Parent] = true
				table.insert(reactable, part.Parent)
			end
		end
	end
	return reactable
end

local function activateHeat(console)
	local objects = getReactableObjects(console)
	for _, object in pairs(objects) do
		Messages:send("ForceCalculateHeatReaction", object)
	end
end

local function activateInvisible(console)
	local objects = getReactableObjects(console)
	for _, object in pairs(objects) do
		Messages:send("TurnInvisible", object)
	end
end

local function initializeConsole(console)
	Messages:send("RegisterDetector", console.Heat.ClickDetector, function(player)
		activateHeat(console)
	end)
	Messages:send("RegisterDetector", console.Invisible.ClickDetector, function(player)
		activateInvisible(console)
	end)
end

local Science = {}

function Science:start()
	for _, console in pairs(CollectionService:GetTagged("ScienceConsole")) do
		initializeConsole(console)
	end
end

return Science
