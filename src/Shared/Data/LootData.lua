local import = require(game.ReplicatedStorage.Shared.Import)
local ToolData = import "Shared/Data/ToolData"

local keycardsWithAccess = {}

local function getToolObject(toolName)
	local tool = Instance.new("Tool")
	tool.Name = toolName
	local data = ToolData[toolName]
	tool.ToolTip = data.description
	tool.TextureId = data.icon
	local model = import(data.model):Clone()
	for _, n in pairs(model:GetChildren()) do
		n.Parent = tool
	end
	return tool
end

local function getKeycardWithAccess(access)
	if not keycardsWithAccess[access] then
		local keycard = getToolObject("Keycard")
		keycard.Parent = game.ServerStorage
		keycardsWithAccess[keycard] = keycard
		keycard.Access.Value = access
	else
		return keycardsWithAccess[access]
	end
end


return {
	Police = {
		getKeycardWithAccess("Security"),
		getKeycardWithAccess("Cook"),
		getToolObject("Security"),
	},
	Captain = {
		getKeycardWithAccess("Captain"),
	},
}
