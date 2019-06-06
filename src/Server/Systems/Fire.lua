local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local LowerHealth = import "Shared/Utils/LowerHealth"
local CollectionService = game:GetService("CollectionService")
local Data = import "Shared/PlayerData"
local flameParticle = import "Assets/Particles/Fire"

local BURN_INTERVAL = 1
local BURN_DAMAGE = 3
local BURN_BUILDING_DAMAGE = 15
local GO_OUT_CHANCE = 5 -- out of 1000
local PLANT_DAMAGE = 1

local function manageBurningHumanoid(object)
	if not object:FindFirstChild("Mask Of Fire") then
		local player = game.Players:GetPlayerFromCharacter(object)
		if player then
			Data:set(player, "lastHit", os.time())
		end
		LowerHealth(object.Humanoid, BURN_DAMAGE, true)
	end
end

local function manageBurningBuilding(object)
	Messages:send("DamageBuilding", object, BURN_BUILDING_DAMAGE)
end

local function manageBurningPlant(object)
	Messages:send("DamagePlant", object, PLANT_DAMAGE)
end

local function manageBurningObject(object)
	if object:FindFirstChild("Humanoid") then
		manageBurningHumanoid(object)
	end
	if CollectionService:HasTag(object, "Building") then
		manageBurningBuilding(object)
	end
	if CollectionService:HasTag(object, "Plant") then
		manageBurningPlant(object)
	end
	if math.random(1, 1000) < GO_OUT_CHANCE then
		Messages:send("Unburn", object)
	end
end

local function onStoppedBurning(object)
	local primaryPart = object.PrimaryPart
	local fire = object:FindFirstChild("Fire", true)
	if fire then
		fire:Destroy()
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
	Messages:send("PlaySound", "Smoke", primaryPart.Position)
	Messages:send("PlayParticle", "Sparks", 15, primaryPart.Position)
end

local function startLoop()
	while wait(BURN_INTERVAL) do
		for _, burningObject in pairs(CollectionService:GetTagged("Burning")) do
			manageBurningObject(burningObject)
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
