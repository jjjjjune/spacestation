--[[
	Generates a name for a player based on their attributes.
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local PlayerNames = import "Shared/Data/PlayerNames"

local t = import "t"

local check = t.tuple(t.string, t.string, t.string)

return function(userId, gender, race)
	assert(check(userId, gender, race))

	local pool = {}

	if gender ~= "Neutral" then
		local poolRef = PlayerNames[gender]
		if poolRef then
			for i = 1,#poolRef do
				local name = poolRef[i]
				table.insert(pool,name)
			end
		end
	end

	local neutralNames = PlayerNames.Neutral
	for i = 1,#neutralNames do
		local name = neutralNames[i]
		table.insert(pool,name)
	end

	return pool
end
