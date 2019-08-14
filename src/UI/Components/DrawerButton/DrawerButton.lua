local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Roact = import "Roact"

local STORE_ICON = "rbxassetid://3493981823"
local SEARCH_ICON = "rbxassetid://3494048854"

local DrawerButton = Roact.PureComponent:extend("DrawerButton")
local player = game.Players.LocalPlayer

local myDrawer

function DrawerButton:init()
	Messages:hook("SetDrawer", function(drawer)
		myDrawer = drawer
	end)
	game:GetService("RunService").RenderStepped:connect(function()
		debug.profilebegin("drawerbutton")
		self:setState({})
		debug.profileend()
	end)
end

function DrawerButton:render()
	if myDrawer then
		local character = player.Character
		local icon = SEARCH_ICON
		local hasTool = false
		if character:FindFirstChildOfClass("Tool") then
			icon = STORE_ICON
			hasTool = true
		end
		local worldPoint = myDrawer.Base.Position
		local camera = workspace.CurrentCamera
		local vector, _= camera:WorldToScreenPoint(worldPoint)
		local screenPoint = Vector2.new(vector.X, vector.Y)
		local color = Color3.new(1,1,1)
		if myDrawer.Tool.Value ~= nil then
			color = Color3.fromRGB(240,255,234)
		end
		return Roact.createElement("ImageButton", {
			Size = UDim2.new(0,64,0,64),
			Position = UDim2.new(0,screenPoint.X,0,screenPoint.Y),
			AnchorPoint = Vector2.new(.5,.5),
			BackgroundTransparency = 1,
			Image = "rbxassetid://3493248592",
			ImageColor3 = color,
			[Roact.Event.Activated] = function()
				if hasTool then
					if myDrawer.Tool.Value == nil then
						Messages:sendServer("DepositTool", myDrawer)
					else
						Messages:sendServer("SearchDrawer", myDrawer)
					end
				else
					Messages:sendServer("SearchDrawer", myDrawer)
				end
			end,
		}, {
			SubImage = Roact.createElement("ImageLabel", {
				Active = false,
				Size = UDim2.new(.5,0,.5,0),
				AnchorPoint = Vector2.new(.5,.5),
				BackgroundTransparency = 1,
				Image = icon,
				Position = UDim2.new(.5,0,.5,0)
			})
		})
	end
end

return DrawerButton
