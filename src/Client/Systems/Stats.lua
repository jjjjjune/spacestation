local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local player = game.Players.LocalPlayer

local playerStats = {
	[1] = {
		name = "Oxygen",
		color = BrickColor.new("Bright blue").Color,
		max = 100,
		current = 100,
		damageTime = 4,
		damage = 15,
		lastDamage = time(),
		icon = "rbxassetid://3489184613"
	},
	[2] = {
		name = "Hunger",
		color = BrickColor.new("Nougat").Color,
		max = 100,
		current = 100,
		damageTime = 5,
		damage = 5,
		lastDamage = time(),
		icon = "rbxassetid://3489170655"
	}
}

local function updateStats()
	Messages:send("UpdateStats", playerStats)
end

local function resetStats()
	for i, statInfo in pairs(playerStats) do
		statInfo.current = statInfo.max
	end
	updateStats()
end

local function oxygenLoop()
	while wait(.5) do
		local character = player.Character
		if character then
			local stat = playerStats[1]
			if not CollectionService:HasTag(character, "Breathing") then
				stat.current = math.max(0, stat.current - 1)
				if time() - stat.lastDamage > stat.damageTime then
					stat.lastDamage = time()
					if character:FindFirstChild("Humanoid") and stat.current <= 0 then
						Messages:sendServer("DamageMe", stat.damage)
					end
				end
			else
				stat.current = math.min(stat.max, stat.current + 10)
			end
		end
		Messages:send("UpdateStats",playerStats)
	end
end

local function hungerLoop()
	while wait(5) do
		local character = player.Character
		if character then
			local stat = playerStats[2]
			stat.current = math.max(0, stat.current - 1)
			if character:FindFirstChild("Humanoid") and stat.current <= 0 then
				Messages:sendServer("DamageMe", stat.damage)
			end
		end
		Messages:send("UpdateStats",playerStats)
	end
end

local Stats = {}

function Stats:start()
	player.CharacterAdded:connect(function(character)
		resetStats()
	end)
	Messages:send("UpdateStats", playerStats)
	Messages:hook("AddHunger", function(hunger)
		playerStats[2].current = math.min(playerStats[2].max, playerStats[2].current + hunger)
	end)
	spawn(oxygenLoop)
	spawn(hungerLoop)
end

return Stats
