local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local CONTAINER_HEIGHT = 50

local lastAmount

local tweenInfo = TweenInfo.new(
	.3, -- Time
	Enum.EasingStyle.Quad, -- EasingStyle
	Enum.EasingDirection.Out
)

local function isInFuel(object)
	if object.Parent ~= workspace then
		return true
	end
	for _, storageInstance in pairs(CollectionService:GetTagged("FuelHolder")) do
		local origin = storageInstance.Base.Position
		local base = storageInstance.Base
		local range = base.Size.X
		local vec1 = (origin + Vector3.new(-range,-(range*4),-range))
		local vec2 = (origin + Vector3.new(range,(range*4),range))
		local region = Region3.new(vec1, vec2)
		local parts = workspace:FindPartsInRegion3(region,nil, 10000)
		for _, part in pairs(parts) do
			if part.Parent == object then
				return true
			end
		end
	end
	return false
end

local function refillFuel(well)
	well.Amount.Value = well.Amount.Value + 50
end

local function updateFuel(well)
	if not lastAmount then
		lastAmount = well.Amount.Value
	else
		if well.Amount.Value > lastAmount then
			Messages:send("PlaySound", "Drinking", well.Base.Position)
		end
	end
	local percent = well.Amount.Value/well.Amount.MaxValue
	for _, fuel in pairs(well:GetChildren()) do
		if fuel.Name == "Fuel" then
			local newSize = Vector3.new(fuel.Size.X, well.Base.Size.Y + (CONTAINER_HEIGHT*percent), fuel.Size.Z)
			local tween = TweenService:Create(fuel, tweenInfo, {Size = newSize})
			tween:Play()
		end
	end
	local newCF = well.Fuel.CFrame * CFrame.new(0,(well.Base.Size.Y + (CONTAINER_HEIGHT*percent))/2,0)
	local tween = TweenService:Create(well.FuelTop, tweenInfo, {CFrame = newCF})
	tween:Play()
	percent = math.ceil(percent * 100)
	well.Display.SurfaceGui.TextLabel.Text = "FUEL REMAINING: "..percent.."%"
	if well.Amount.Value <= 0 then
		Messages:send("OpenAllDoors")
	end
end

local function initializeFuel(well)
	local amount = Instance.new("IntConstrainedValue")
	amount.MaxValue = 1000
	amount.Value = 750
	amount.Name = "Amount"
	amount.Parent = well
	amount:GetPropertyChangedSignal("Value"):connect(function()
		updateFuel(well)
	end)
end

local Fuel = {}

function Fuel:start()
	for _, well in pairs(CollectionService:GetTagged("FuelHolder")) do
		initializeFuel(well)
		updateFuel(well)
	end
	Messages:hook("OnObjectReleased", function(player, object)
		for _, well in pairs(CollectionService:GetTagged("FuelHolder")) do
			if CollectionService:HasTag(object, "Fuel") then
				if isInFuel(object) then
					refillFuel(well)
					object:Destroy()
				end
			end
		end
	end)
end

return Fuel
