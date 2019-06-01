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
		["Stone"] = 4,
	},
}
data["Wood Wall"] = {
	recipe = {
		["Log"] = 4,
	},
}
data["Small Storage"] = {
	recipe = {
		["Log"] = 2,
	},
}
data["Large Storage"] = {
	recipe = {
		["Log"] = 3,
	},
}
data["Campfire"] = {
	recipe = {
		["Coal"] = 2,
		["Log"] = 2,
	},
}
data["Torch"] = {
	recipe = {
		["Coal"] = 1,
		["Stick"] = 1,
	},
}
data["Wood Hut"] = {
	recipe = {
		["Log"] = 8,
	},
}
data["Wood Cage"] = {
	recipe = {
		["Log"] = 8,
	},
}
data["Door"] = {
	recipe = {
		["Log"] = 1,
	},
}
data["Chair"] = {
	recipe = {
		["Log"] = 1,
	},
}
data["Furnace"] = {
	recipe = {
		["Stone"] = 2,
		["Coal"] = 2,
	},
}
data["Grindstone"] = {
	recipe = {
		["Stone"] = 4,
	},
}
data["Sailboat"] = {
	recipe = {
		["Log"] = 6,
		["Rope"] = 6,
	},
	water = true,
}
data["Longship"] = {
	recipe = {
		["Log"] = 1,
		--["Rope"] = 6,
	},
	water = true,
}
data["Well"] = {
	recipe = {
		["Stone"] = 8,
		["Log"] =2,
		["Rope"] = 2,
	},
}
data["Compost Bin"] = {
	recipe = {
		["Apple"] = 2,
		["Acorn"] = 2,
	},
}
data["Cannon"] = {
	recipe = {
		["Iron Bar"] = 2,
		["Gunpowder"] =2,
	}
}
data["Tannery"] = {
	recipe = {
		["Stone"] = 12,
	}
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
