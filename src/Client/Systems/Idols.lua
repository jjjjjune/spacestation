local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local IdolsList = import "Shared/Data/Idols"

local CollectionService = game:GetService("CollectionService")

local function prepareIdol(idol)
	local display = import("Assets/Idols/"..idol.Name):Clone()
	display.Name = "Display"
	display.PrimaryPart = display.Base
	display.Parent = idol
	display:SetPrimaryPartCFrame(idol.Base.CFrame * CFrame.new(0, 5,0))
end

local function manageIdols()
	for _, idol in pairs(CollectionService:GetTagged("Idol")) do
		idol.Display:SetPrimaryPartCFrame(idol.Display.PrimaryPart.CFrame * CFrame.Angles(0,math.rad(1),0))
		local info = IdolsList[idol.Name]
		local stat = info.stat
		local myAmount = _G.Data[stat]
		local needed = info.needed
		local descriptionText = myAmount.."/"..needed.." "..info.verb
		if myAmount > needed then
			descriptionText = "CLICK TO EQUIP"
		end
		local nameText = string.upper(info.name)
		idol.RequirementLabel.SurfaceGui.TextLabel.Text = descriptionText
		idol.DescriptionLabel.SurfaceGui.TextLabel.Text = info.description
		idol.NameLabel.SurfaceGui.TextLabel.Text = nameText
	end
end

local Idols = {}

function Idols:start()
	for _, idol in pairs(CollectionService:GetTagged("Idol")) do
		prepareIdol(idol)
	end
	game:GetService("RunService").RenderStepped:connect(function()
		manageIdols()
	end)
end

return Idols
