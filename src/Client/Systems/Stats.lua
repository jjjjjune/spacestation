local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local player = game.Players.LocalPlayer

local playerStats = {
	[1] = {
		name = "Oxygen",
		color = Color3.fromRGB(157,255,183),
		secondaryColor = Color3.fromRGB(186,255,222),
		max = 100,
		current = 100,
		damageTime = 4,
		damage = 15,
		lastDamage = time(),
		icon = "rbxassetid://3678020046"
	},
	[2] = {
		name = "Hunger",
		color = Color3.fromRGB(255,141,141),
		secondaryColor = Color3.fromRGB(255,212,212),
		max = 50,
		current = 50,
		damageTime = 100,
		damage = 0,
		lastDamage = time(),
		icon = "rbxassetid://3678024836"
	}
}

local function updateStats()
	Messages:send("UpdateStats", playerStats)
	Messages:sendServer("SetHunger", playerStats[2].current)
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
		updateStats()
	end
end

local function hungerLoop()
	while wait(10) do
		local character = player.Character
		if character then
			local stat = playerStats[2]
			stat.current = math.max(0, stat.current - 1)
			if character:FindFirstChild("Humanoid") and stat.current <= 0 then
				Messages:sendServer("DamageMe", stat.damage)
			end

		end
		updateStats()
	end
end

local Stats = {}

function Stats:start()
	player.CharacterAdded:connect(function(character)
		resetStats()
	end)
	updateStats()
	Messages:hook("AddHunger", function(hunger)
		playerStats[2].current = math.min(playerStats[2].max, playerStats[2].current + hunger)
	end)
	spawn(oxygenLoop)
	spawn(hungerLoop)
end

return Stats
