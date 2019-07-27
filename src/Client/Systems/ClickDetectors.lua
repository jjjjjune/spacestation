local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local UserInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer

local detectors = {}

local ClickDetectors = {}

function ClickDetectors:start()

	for _, dec in pairs(workspace:GetDescendants()) do
		if dec:IsA("ClickDetector") then
			detectors[dec] = dec.Parent.Position
		end
	end
	workspace.DescendantAdded:connect(function(dec)
		if dec:IsA("ClickDetector") then
			detectors[dec] = dec.Parent.Position
		end
	end)
	game:GetService("RunService").RenderStepped:connect(function()
		local character = player.Character
		local nearbyDetectorsTable = {}
		if character and not character:FindFirstChild("Grab") then
			local root = character.PrimaryPart
			if root then
				local closestDist = 14
				for dec, pos in pairs(detectors) do
					detectors[dec] = dec.Parent.Position
					pos =dec.Parent.Position
					if dec.Parent ~= nil then
						local dist = (pos - root.Position).magnitude
						if dist < closestDist then
							table.insert(nearbyDetectorsTable, dec)
						end
					else
						detectors[dec] = nil
					end
				end
			end
		end
		Messages:send("SetNearbyDetectors", nearbyDetectorsTable)
	end)
end

return ClickDetectors
