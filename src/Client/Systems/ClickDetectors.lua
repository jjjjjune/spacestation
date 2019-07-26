local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local UserInputService = game:GetService("UserInputService")

local player = game.Players.LocalPlayer

local detectors = {}
local nearbyDetector
local nearbyDetectorsTable = {}

local ClickDetectors = {}

function ClickDetectors:start()
	local clickButton = Instance.new("ImageButton", player:WaitForChild("PlayerGui"):WaitForChild("GameUI"))
	clickButton.Size = UDim2.new(0,48,0,48)
	clickButton.Image = "rbxassetid://3540399251"
	clickButton.Visible = false
	clickButton.BackgroundTransparency = 1
	clickButton.Activated:connect(function()
		Messages:sendServer("PlayerClicked", lastNearbyDetector)
		print("yeah sending", lastNearbyDetector, lastNearbyDetector.Parent, lastNearbyDetector.Parent.Parent)
	end)

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
	--[[UserInputService.InputEnded:connect(function(inputObject, gameProcessed)
		if not gameProcessed then
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				local targ = player:GetMouse().target
				if targ then
					if targ:FindFirstChild("ClickDetector") then
						if (player:GetMouse().Hit.p - player.Character.Head.Position).magnitude < targ.ClickDetector.MaxActivationDistance then

						end
					end
				end
			end
		end
	end)--]]
	game:GetService("RunService").RenderStepped:connect(function()
		nearbyDetector = nil
		local character = player.Character
		if character then
			local root = character.PrimaryPart
			if root then
				local closestDist = 12
				nearbyDetectorsTable = {}
				for dec, pos in pairs(detectors) do
					if dec.Parent ~= nil then
						local dist = (pos - root.Position).magnitude
						if dist < closestDist and dist < dec.MaxActivationDistance then
							table.insert(nearbyDetectorsTable, dec)
						end
					else
						detectors[dec] = nil
					end
				end
			end
		end
		Messages:send("SetNearbyDetectors", nearbyDetectorsTable)
		--[[if nearbyDetector then
			lastNearbyDetector = nearbyDetector
			clickButton.Visible = true
			local camera = workspace.CurrentCamera
			local vector, onScreen = camera:WorldToScreenPoint(nearbyDetector.Parent.Position)
			clickButton.Position = UDim2.new(0, vector.X, 0, vector.Y)
		else
			lastNearbyDetector = nil
			clickButton.Visible = false
		end--]]
	end)
end

return ClickDetectors
