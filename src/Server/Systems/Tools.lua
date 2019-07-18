local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ToolData = import "Shared/Data/ToolData"

local function connectEvents(tool)
	local behavior = import("Server/ToolBehaviors/"..tool.Name).new()
	behavior:instance(tool)
end

local function getToolObject(toolName)
	local tool = Instance.new("Tool")
	tool.Name = toolName
	local data = ToolData[toolName]
	tool.TextureId = data.icon
	local model = import(data.model):Clone()
	for _, n in pairs(model:GetChildren()) do
		n.Parent = tool
	end
	spawn(function()
		repeat wait() until tool.Parent ~= nil
		connectEvents(tool)
	end)
	return tool
end

local Tools = {}

function Tools:start()
	Messages:hook("GiveTool", function(player, toolName)
		local tool = getToolObject(toolName)
		tool.Parent = player.Backpack
	end)
	Messages:hook("RemoveTool", function(player, toolName)
		player.Backpack[toolName]:Destroy()
	end)
	game.Players.PlayerAdded:connect(function(player)
		player.CharacterAdded:connect(function(character)
			Messages:send("GiveTool", player, "Flashlight")
		end)
	end)
end

return  Tools
