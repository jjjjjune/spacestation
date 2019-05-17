local import = require(game.ReplicatedStorage.Shared.Import)

return function(race)
	local raceAsset = import("Assets/Races/"..race)
	local info = {
		maxHealth = raceAsset.Humanoid.MaxHealth,
		walkSpeed = raceAsset.Humanoid.WalkSpeed,
		jumpPower = raceAsset.Humanoid.JumpPower,
		skinColor = raceAsset.Head.BrickColor
	}
	return info
end
