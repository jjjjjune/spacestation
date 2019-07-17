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
		damageTime = .5,
		damage = 1,
		lastDamage = time()
	},
	[2] = {
		name = "Hunger",
		color = BrickColor.new("Nougat").Color,
		max = 100,
		current = 100,
		damageTime = 5,
		damage = 5,
		lastDamage = time()
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
	while wait() do
		local character = player.Character
		if character then
			local stat = playerStats[1]
			if not CollectionService:HasTag(character, "Breathing") then
				stat.current = math.max(0, stat.current - 1)
				if time() - stat.lastDamage > stat.damageTime then
					stat.lastDamage = time()
					if character:FindFirstChild("Humanoid") then
						character.Humanoid:TakeDamage(stat.damage)
					end
				end
			else
				stat.current = math.min(stat.max, stat.current + 100)
			end
		end
	end
end

local Stats = {}

function Stats:start()
	player.CharacterAdded:connect(function(character)
		resetStats()
	end)
	Messages:send("UpdateStats", playerStats)
	spawn(oxygenLoop)
end

return Stats
