local import = require(game.ReplicatedStorage.Shared.Import)
local TeamData = import "Shared/Data/TeamData"

local function hasAccess(accessTable, needed)
	for _, ownedAccess in pairs(accessTable) do
		if ownedAccess == needed then
			return true
		end
	end
	return false
end

return function(player)
	local backpack = player.Backpack
	local playerData = TeamData[player.Team.Name]
	local playerAccessTable = playerData.access
	for _, tool in pairs(player.Character:GetChildren()) do
		if tool:IsA("Tool") then
			if tool:FindFirstChild("Access") then
				local neededAccess = tool.Access.Value
				if not hasAccess(playerAccessTable, neededAccess) then
					return true
				end
			end
		end
	end
	for _, tool in pairs(backpack:GetChildren()) do
		if tool:IsA("Tool") then
			if tool:FindFirstChild("Access") then
				local neededAccess = tool.Access.Value
				if not hasAccess(playerAccessTable, neededAccess) then
					return true
				end
			end
		end
	end
	return false
end
