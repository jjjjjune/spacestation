local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local LowerHealth = import "Shared/Utils/LowerHealth"
local CollectionService = game:GetService("CollectionService")
local Data = import "Shared/PlayerData"
local flameParticle = import "Assets/Particles/Fire"
local PlayerData = import "Shared/PlayerData"

local BURN_INTERVAL = 1
local BURN_DAMAGE = .5
local BURN_BUILDING_DAMAGE = 15
local GO_OUT_CHANCE = 5 -- out of 1000
local PLANT_DAMAGE = 1
local SPREAD_TIME = 5 -- fire spread tick everyt his many seconds

local lastChecksTable = {} -- we only wanna check for nearby burnables like once every 10 seconds or so per burnable

local function getRegion(character)
	if not character.PrimaryPart then
		return nil
	end
	local xRange = character:GetModelSize().X + 4
	local yRange = character:GetModelSize().Y + 4
	local zRange = character:GetModelSize().Z + 4
	local vec1 = (character.PrimaryPart.Position + Vector3.new(-xRange,-yRange,-zRange))
	local vec2 = (character.PrimaryPart.Position + Vector3.new(xRange,yRange,zRange))
	local region = Region3.new(vec1, vec2)
	return region
end

local function manageBurningHumanoid(object)
	if object.Humanoid.Health > 0 then
		local dmg = object.Humanoid.MaxHealth*.025
		LowerHealth(nil, object, dmg)
	end
end

local function manageBurningBuilding(object)
	Messages:send("DamageBuilding", object, BURN_BUILDING_DAMAGE)
end

local function manageBurningPlant(object)
	Messages:send("DamagePlant", object, PLANT_DAMAGE)
end

local function checkNearbyBurnables(object)

	if not lastChecksTable[object] then -- this little bit is just a quick debounce for the fire spreading
		lastChecksTable[object] = time()
		return
	else
		if time() - lastChecksTable[object] < SPREAD_TIME then
			return
		else
			lastChecksTable[object] = time()
		end
	end

	local region = getRegion(object)
	if region then
		for _, part in pairs(workspace:FindPartsInRegion3(region)) do
			local object = part.Parent
			local isPlant = false--CollectionService:HasTag(object, "Plant")
			local isMonster = object:FindFirstChild("Humanoid")
			local isFlammableBuilding =(CollectionService:HasTag(object, "Building") and CollectionService:HasTag(object, "Flammable"))
			local isFlammableObject = (CollectionService:HasTag(object, "Carryable")) and CollectionService:HasTag(object, "Flammable")
			if isPlant or isMonster or isFlammableBuilding or isFlammableObject then
				if not CollectionService:HasTag(object, "Burning") then
					Messages:send("Burn", object)
				end
			end
		end
	end
end

local function manageBurningObject(object)
	if object:FindFirstChild("Humanoid") then
		manageBurningHumanoid(object)
	end
	if CollectionService:HasTag(object, "Building") and CollectionService:HasTag(object, "Flammable") then
		manageBurningBuilding(object)
	end
	if CollectionService:HasTag(object, "Plant") then
		manageBurningPlant(object)
	end
	if math.random(1, 1000) < GO_OUT_CHANCE then
		Messages:send("Unburn", object)
	end
	checkNearbyBurnables(object)
end

local function onStoppedBurning(object)
	local primaryPart = object.PrimaryPart
	local fire = object:FindFirstChild("Fire", true)
	if fire then
		fire:Destroy()
		if primaryPart:FindFirstChild("fireLight") then
			primaryPart.fireLight:Destroy()
		end
	end
	Messages:send("PlaySound", "Fireputout", primaryPart.Position)
end

local function onStartedBurning(object)
	local primaryPart = object.PrimaryPart
	if primaryPart:FindFirstChild("Fire") then
		return -- already burning
	end
	local flames = flameParticle:Clone()
	flames.Parent = primaryPart
	local fireLight = Instance.new("PointLight", primaryPart)
	fireLight.Brightness = .5
	fireLight.Name = "FireLight"
	fireLight.Color = BrickColor.new("Bright orange").Color
	Messages:send("PlaySound", "Smoke", primaryPart.Position)
	Messages:send("PlayParticle", "Sparks", 15, primaryPart.Position)
end

local function startLoop()
	while wait(BURN_INTERVAL) do
		for _, burningObject in pairs(CollectionService:GetTagged("Burning")) do
			spawn(function() manageBurningObject(burningObject) end)
		end
	end
end

local Fire = {}

function Fire:start()
	spawn(function()
		startLoop()
	end)
	Messages:hook("Burn", function(player, object)
		if not player:IsDescendantOf(game.Players) then
			object = player
		end
		CollectionService:AddTag(object, "Burning")
		onStartedBurning(object)
	end)
	Messages:hook("Extinguish", function(object)
		CollectionService:RemoveTag(object, "Burning")
		onStoppedBurning(object)
	end)
	Messages:hook("Unburn", function(player, object)
		if not player:IsDescendantOf(game.Players) then
			object = player
		else
			Data:add(player, "FiresExtenguished", 1)
		end
		CollectionService:RemoveTag(object, "Burning")
		onStoppedBurning(object)
	end)
end

return Fire
