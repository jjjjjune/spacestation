local import = require(game.ReplicatedStorage.Shared.Import)
local ToolData = import "Shared/Data/ToolData"

local keycardsWithAccess = {}

local function getToolObject(toolName)
	local tool = Instance.new("Tool")
	tool.Name = toolName
	local data = ToolData[toolName]
	tool.ToolTip = data.description
	tool.TextureId = data.icon
	tool.CanBeDropped = false
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
		keycard.Team.Value = access
		keycard.Indicator.BrickColor = game.Teams[access].TeamColor
		keycard.ToolTip = keycard.ToolTip.." ["..access:upper().."]"
		return keycard
	else
		return keycardsWithAccess[access]
	end
end

return {
	Security = {
		getKeycardWithAccess("Security"),
		getKeycardWithAccess("Cooks"),
		getToolObject("Pistol"),
	},
	Captain = {
		getKeycardWithAccess("Captain"),
	},
}
