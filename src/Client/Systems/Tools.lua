local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local player = game.Players.LocalPlayer

local instanced = {}

local toolBehavior

local  Tools = {}

function Tools:start()
	player:WaitForChild("Backpack").ChildAdded:connect(function(tool)
		if tool:IsA("Tool") and not instanced[tool] then
			spawn(function()
				toolBehavior = import("Client/ToolBehaviors/"..tool.Name).new()
				toolBehavior:instance(tool)
				instanced[tool] = true
			end)
		end
	end)
end

return Tools
