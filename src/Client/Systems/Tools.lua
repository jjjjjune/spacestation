local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local player = game.Players.LocalPlayer

local instanced = {}

local toolBehavior

local function initTool(tool)
	if tool:IsA("Tool") and not instanced[tool] then
		toolBehavior = import("Client/ToolBehaviors/"..tool.Name).new()
		toolBehavior:instance(tool)
		instanced[tool] = true
	end
end

local  Tools = {}

function Tools:start()
	spawn(function()
		player:WaitForChild("Backpack").ChildAdded:connect(function(tool)
			initTool(tool)
		end)
		player.CharacterAdded:connect(function(character) -- we do this because of a wierd bug wehre childadded doesnt fire on Backpack
			-- when the character first gets added
			for _, tool in pairs(player.Backpack:GetChildren()) do
				initTool(tool)
			end
		end)
	end)
end

return Tools
