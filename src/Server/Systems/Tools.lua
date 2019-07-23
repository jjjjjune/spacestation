local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local ToolData = import "Shared/Data/ToolData"
local TeamData = import "Shared/Data/TeamData"
local PlayerData = import "Shared/PlayerData"

local behaviorsCache = {}
local instanced = {}

local function connectEvents(tool)
	if not instanced[tool] then
		instanced[tool] = true
		local behavior = import("Server/ToolBehaviors/"..tool.Name).new()
		behavior:instance(tool)
	end
end

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
	spawn(function()
		if tool.Parent == nil then
			repeat wait() until tool.Parent ~= nil
		end
		connectEvents(tool)
	end)
	return tool
end

local Tools = {}

function Tools:start()
	workspace.ChildAdded:connect(function(tool)
		if tool:IsA("Tool") then
			for _, player in pairs(game.Players:GetChildren()) do
				local character = player.Character
				if character then
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					if humanoidRootPart then
						if (humanoidRootPart.Position - tool.Handle.Position).magnitude < 10 then
							tool.Handle:BreakJoints()
							for _, p in pairs(tool:GetChildren()) do
								if p:IsA("BasePart") then
									local w = Instance.new("WeldConstraint", tool.Handle)
									w.Part0 = p
									w.Part1 = tool.Handle
								end
							end

							tool.Parent = workspace
							tool.Handle.CFrame = humanoidRootPart.CFrame * CFrame.new(0,0,-10)
							break
						end
					end
				end
			end
		end
	end)
	Messages:hook("GiveTool", function(player, toolName)
		local tool = getToolObject(toolName)
		tool.Parent = player.Backpack
	end)
	Messages:hook("RemoveTool", function(player, toolName)
		player.Backpack[toolName]:Destroy()
	end)
	Messages:hook("BuyTool", function(player, shop)
		local cash = PlayerData:get(player, "cash")
		local price = shop.Price.Value
		if cash >= price then
			PlayerData:add(player, "cash", -price)
			Messages:send("GiveTool", player, shop.Tool.Value)
			Messages:send("PlaySound", "Chime", shop.Base.Position)
		else
			Messages:send("PlaySound", "Error", shop.Base.Position)
		end
	end)
end

return  Tools
