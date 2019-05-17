local data = {}

data["Raft"] = {
	recipe = {
		["Log"] = 1,
		["Stick"] = 1,
	},
	water = true,
}
data["Stone Wall"] = {
	recipe = {
		["Log"] = 2,
		["Stone"] = 8,
	},
}
data["Wood Wall"] = {
	recipe = {
		["Log"] = 8,
	},
}
data["Small Storage"] = {
	recipe = {
		["Log"] = 4,
	},
}
data["Large Storage"] = {
	recipe = {
		["Log"] = 6,
	},
}
data["Campfire"] = {
	recipe = {
		["Coal"] = 2,
		["Log"] = 2,
	},
}

for _,  building in pairs(game.ReplicatedStorage.Assets.Buildings:GetChildren()) do
	if not data[building.Name] then
		data[building.Name] = {
			water = false,
			recipe = {
				["Stick"] = 1,
			}
		}
	end
end

return data
