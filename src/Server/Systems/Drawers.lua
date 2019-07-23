local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local function searchDrawer(player, drawer)
	if drawer.Tool.Value ~= nil then
		drawer.Tool.Value.Parent = player.Character
		drawer.Tool.Value = nil
	end
end

local function depositTool(player, drawer)
	local tool = player.Character:FindFirstChildOfClass("Tool")
	tool.Parent = game.Lighting
	drawer.Tool.Value = tool
end

local Drawers = {}

function Drawers:start()
	for _, drawer in pairs(CollectionService:GetTagged("Drawer")) do
		local tool = Instance.new("ObjectValue", drawer)
		tool.Name = "Tool"
	end
	Messages:hook("SearchDrawer", function(player, drawer)
		searchDrawer(player,drawer)
	end)
	Messages:hook("DepositTool", function(player, drawer)
		searchDrawer(player, drawer)
		depositTool(player, drawer)
	end)
end

return Drawers
