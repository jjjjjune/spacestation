local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")

local function orderSupply(crate)
	if crate.Quantity.Value > 0 then
		crate.Quantity.Value = crate.Quantity.Value - 1
		local asset = game.ReplicatedStorage.Assets.Objects[crate.ItemName.Value]:Clone()
		asset.Parent = workspace
		asset.PrimaryPart = asset.Base
		asset:SetPrimaryPartCFrame(crate.Base.CFrame * CFrame.new(0,3,0))
		crate.Button.SurfaceGui.TextLabel.Text = crate.Quantity.Value..""
		if crate.Quantity.Value == 0 then
			crate.Button.BrickColor = BrickColor.new("Bright red")
			crate:Destroy()
			return
		end
		Messages:send("PlaySound", "ErrorLight", asset.Base.Position)
		Messages:send("PlayParticle", "Sparks", 15, asset.Base.Position)
	end
end

local function setupCrate(crate)
	crate.Display.SurfaceGui.TextLabel.Text = crate.ItemName.Value
	Messages:send("RegisterDetector", crate.Button.ClickDetector, function(player)
		orderSupply(crate)
	end)
end

local Crates = {}

function Crates:start()
	workspace.ChildAdded:connect(function(crate)
		CollectionService:GetInstanceAddedSignal("Supply"):connect(function(crate)
			setupCrate(crate)
		end)
	end)
	for _, crate in pairs(CollectionService:GetTagged("Supply")) do
		setupCrate(crate)
	end
	Messages:hook("OrderSupply", function(crate)
		orderSupply(crate)
	end)
end

return Crates

