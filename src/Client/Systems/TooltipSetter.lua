local import = require(game.ReplicatedStorage.Shared.Import)

local Store = import "Shared/State/Store"
local Messages = import "Shared/Utils/Messages"
local SetTooltipName = import "Shared/Actions/Tooltips/SetTooltipName"
local SetTooltipPosition = import "Shared/Actions/Tooltips/SetTooltipPosition"
local SetTooltipDescription = import "Shared/Actions/Tooltips/SetTooltipDescription"
local SetTooltipButton = import "Shared/Actions/Tooltips/SetTooltipButton"
local SetTooltipVisible  = import "Shared/Actions/Tooltips/SetTooltipVisible"
local Player = game.Players.LocalPlayer
local Mouse = Player:GetMouse()

local CollectionService = game:GetService("CollectionService")

local TooltipSetter = {}

local viewRange = 80
local player = game.Players.LocalPlayer

local tooltipSettings = {
	{
		validityCheck = function(part)
			local check = part.Parent
			if CollectionService:HasTag(check, "Item") and check.Parent == workspace then
				return part.Parent
			end
			return nil
		end,
		descriptionGetter = function(model)
			return "no one really knows what this is"
		end,
		hotkey = "E",
	},
	{
		validityCheck = function(part)
			local check = part.Parent
			if CollectionService:HasTag(check, "Water") then
				return part.Parent
			end
			return nil
		end,
		descriptionGetter = function(model)
			return model.Quantity.Value.."/"..model.Quantity.MaxValue
		end,
		hotkey = "E",
	},
	{
		validityCheck = function(part)
			local check = part.Parent
			if CollectionService:HasTag(check, "Ragdolled") and check~= player.Character then
				return part.Parent
			end
			return nil
		end,
		descriptionGetter = function(model)
			return "R to drag, X to execute"
		end,
		hotkey = "R, X",
	},
}

local function inRange()
	if player.Character then
		if player.Character.PrimaryPart then
			if (player.Character.PrimaryPart.Position - Mouse.Hit.p).magnitude < viewRange then
				return true
			end
		end
	end
	return false
end

function TooltipSetter:start()
	game:GetService("RunService").RenderStepped:connect(function()
		if Mouse.Target and inRange() then
			for _, tooltipSetting in pairs(tooltipSettings) do
				local check = Mouse.Target
				local result = tooltipSetting.validityCheck(check)
				if result then
					local pos
					if result:FindFirstChild("Base") then
						pos = result.Base.Position
					else
						pos = result.PrimaryPart.Position
					end
					local resultScreenPos = workspace.CurrentCamera:WorldToScreenPoint(pos)
					Store:dispatch(SetTooltipName(result.Name))
					Store:dispatch(SetTooltipPosition(UDim2.new(0,resultScreenPos.X,0,resultScreenPos.Y - 10)))
					Store:dispatch(SetTooltipButton(tooltipSetting.hotkey))
					Store:dispatch(SetTooltipDescription(tooltipSetting.descriptionGetter(result)))
					Store:dispatch(SetTooltipVisible(true))
					break
				else
					Store:dispatch(SetTooltipVisible(false))
				end
			end
		else
			Store:dispatch(SetTooltipVisible(false))
		end
	end)
end

return TooltipSetter
