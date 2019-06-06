local import = require(game.ReplicatedStorage.Shared.Import)

local ItemsUtil = import "Shared/Utils/Items"
local UserInputService = game:GetService("UserInputService")
local Messages = import "Shared/Utils/Messages"

local player = game.Players.LocalPlayer

local GRAB_DISTANCE = 10
local DRINK_DISTANCE = 20

local ItemGrab = {}

local function getMousePosition()
	return game.Players.LocalPlayer:GetMouse().Hit.p
end

local function isAlive()
	return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and not player.Character:FindFirstChildOfClass("ForceField", true)
end

function ItemGrab:start()
	UserInputService.InputBegan:connect(function(inputObject, gameProcessed)
		if inputObject.KeyCode == Enum.KeyCode.E and not gameProcessed then
			local pos = getMousePosition()
			local item = ItemsUtil.getNearestTagToPosition("Item", pos, GRAB_DISTANCE)
			if item and isAlive() then
				Messages:sendServer("GrabItem", item)
			end
			local water = ItemsUtil.getNearestTagToPosition("Water", player.Character.HumanoidRootPart.Position, "inside")
			if water and isAlive() then
				Messages:sendServer("DrinkWater", water)
			end
		end
	end)
end

return ItemGrab
