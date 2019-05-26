local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local SacrificePoints = import "Shared/Data/SacrificePoints"
local PlayerData = import "Shared/PlayerData"

local CollectionService = game:GetService("CollectionService")

local SacrificeProgress = {}

function SacrificeProgress:start()
	spawn(function()
		while wait(1) do
			local godProgress = CollectionService:GetTagged("GodProgress")
			for _, progressBar in pairs(godProgress) do
				local godName = progressBar.Name
				local value = _G.Data.sacrifices[godName] or 0
				if value then
					for _, part in pairs(progressBar:GetChildren()) do
						if tonumber(part.Name) <= value then
							part.Material = Enum.Material.Neon
						else
							part.Material = Enum.Material.SmoothPlastic
						end
					end
				end
			end
			local godGates = CollectionService:GetTagged("Sacrifice Gate")
			for _, progressBar in pairs(godGates) do
				local godName = progressBar.Name
				local value = _G.Data.sacrifices[godName] or 0
				if value then
					if value >= progressBar.Amount.Value then
						progressBar.Parent = game.ReplicatedStorage
					else
						progressBar.Parent = workspace
					end
				end
			end
		end
	end)
end

return SacrificeProgress
