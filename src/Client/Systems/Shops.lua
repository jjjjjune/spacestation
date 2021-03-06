local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local ToolData = import "Shared/Data/ToolData"
local TweenService = game:GetService("TweenService")

local MAX_DISTANCE = 10

local shopProps = {}
local baseCFs = {}
local lastShop
local player = game.Players.LocalPlayer
local originalColors = {}
local tweenInfo = TweenInfo.new(
	2,
	Enum.EasingStyle.Back,
	Enum.EasingDirection.Out,
	0
)
local tweenInfoFast = TweenInfo.new(
	.8,
	Enum.EasingStyle.Back,
	Enum.EasingDirection.Out,
	0
)

local lastSound = time()

local function close(shop)
	if not originalColors[shop] then
		originalColors[shop] = shop.PlatformDisplay.Color
	end
	local startCol = originalColors[shop]
	if shop.Open.Value == true then
		shop.Open.Value = false
		shop.PrimaryPart = shop.Base
		shop.PlatformDisplay.Material = Enum.Material.Neon
		local tween = TweenService:Create(shop.PlatformDisplay,tweenInfoFast, {Color = startCol})
		tween:Play()
		if time() - lastSound > 2 then
			Messages:sendServer("PlaySoundServer", "Lift", shop.Platform.Position)
		end
		tween = TweenService:Create(shop.Platform,tweenInfo, {CFrame = shop.Platform.CFrame * CFrame.new(0,-1,0)})
		tween:Play()
		if time() - lastSound > 2 then
			Messages:sendServer("PlaySoundServer", "Shop2", shop.Platform.Position, "Static")
			lastSound = time()
		end
	end
end


local function open(shop)
	if not originalColors[shop] then
		originalColors[shop] = shop.PlatformDisplay.Color
	end
	local startCol = originalColors[shop]
	if not shop:FindFirstChild("Open") then
		local openValue = Instance.new("BoolValue",shop)
		openValue.Name = "Open"
		openValue.Value = false
	end
	if shop.Open.Value == false then
		shop.Open.Value = true
		if lastShop and lastShop ~= shop then
			close(lastShop)
		end
		lastShop = shop
		shop.PrimaryPart = shop.Base
		local tween = TweenService:Create(shop.PlatformDisplay,tweenInfoFast, {Color = Color3.new(startCol.r + .2, startCol.g + .2, startCol.b + .2)})
		tween:Play()
		if time() - lastSound > 2 then
			Messages:sendServer("PlaySoundServer", "Unlift", shop.Platform.Position)
		end
		tween = TweenService:Create(shop.Platform,tweenInfo, {CFrame = shop.Platform.CFrame * CFrame.new(0,1,0)})
		tween:Play()
		if time() - lastSound > 2 then
			Messages:sendServer("PlaySoundServer", "Shop1", shop.Platform.Position, "Static")
			lastSound = time()
		end
	end
end

local function getClosestShop(position)
	local closestDist = MAX_DISTANCE
	local closestShop = nil
	for _, shop in pairs(CollectionService:GetTagged("Shop")) do
		local dist = (shop.Base.Position - position).magnitude
		if dist < closestDist then
			closestShop = shop
			closestDist = dist
		end
	end
	return closestShop
end

local function prepareShop(shop)
	local toolName = shop.Tool.Value
	local data = ToolData[toolName]
	local toolModelPath = data.model
	local toolModel = import(toolModelPath):Clone()
	local desiredCF = CFrame.new(0,2,0)
	toolModel.Parent = shop
	toolModel.Handle.CFrame = shop.Platform.CFrame * desiredCF
	shop.Label.SurfaceGui.TextLabel.Text = "$"..shop.Price.Value
	baseCFs[toolModel.Handle] = desiredCF
	local model = Instance.new("Model", shop) -- store it in a new model so it isnt a tool
	model.Name = "Prop"
	for _, part in pairs(toolModel:GetChildren()) do
		if part:IsA("BasePart") then
			part.Anchored = true
			part.Parent = model
		end
	end
	model.PrimaryPart = model.Handle
	table.insert(shopProps, model)
end

local function animateShopProps()
	for _, prop in pairs(shopProps) do
		local shop = prop.Parent
		local originalCFrame = baseCFs[prop.PrimaryPart]
		baseCFs[prop.PrimaryPart] = originalCFrame * CFrame.Angles(0, math.rad(1),0)
		prop:SetPrimaryPartCFrame(shop.Platform.CFrame * originalCFrame * CFrame.new(0, math.sin(time())/2,0))
	end
end

local lastShopUiTick = time()

local function manageShopUi()
	if time() - lastShopUiTick < .25 then
		return
	else
		lastShopUiTick = time()
	end
	local character = player.Character
	if character then
		local root = character.PrimaryPart
		if root then
			local shop = getClosestShop(root.Position)
			if shop then
				open(shop)
				Messages:send("SetShop", shop)
				return
			else
				if lastShop and lastShop ~= shop and math.ceil((lastShop.Base.Position - player.Character.PrimaryPart.Position).magnitude) > MAX_DISTANCE + 1 then
					close(lastShop)
					lastShop = nil
				end
			end
		end
	end
	Messages:send("SetShop", nil)
end

local function refreshShopUnlocks(stat)
	stat = stat or _G.Data.unlocks
	for _, shop in pairs(CollectionService:GetTagged("Shop")) do
		if shop:FindFirstChild("UnlockPrice") then
			if not stat[shop.Tool.Value] then
				shop.Label.BrickColor = BrickColor.new("Terra Cotta")
				shop.PlatformDisplay.BrickColor = BrickColor.new("Persimmon")
				shop.Label.SurfaceGui.TextLabel.Text = "$"..shop.UnlockPrice.Value
				originalColors[shop] = shop.Label.Color
			else
				shop.Label.BrickColor = BrickColor.new("Bright blue")
				if shop.PlatformDisplay.BrickColor == BrickColor.new("Persimmon") then
					shop.PlatformDisplay.BrickColor = BrickColor.new("Medium blue")
				end
				shop.Label.SurfaceGui.TextLabel.Text = "$"..shop.Price.Value
				originalColors[shop] = shop.Label.Color
			end
		else
			shop.Label.BrickColor = BrickColor.new("Bright blue")
			if shop.PlatformDisplay.BrickColor == BrickColor.new("Persimmon") then
				shop.PlatformDisplay.BrickColor = BrickColor.new("Medium blue")
			end
			shop.Label.SurfaceGui.TextLabel.Text = "$"..shop.Price.Value
			originalColors[shop] = shop.Label.Color
		end
	end
end

local Shops = {}

function Shops:start()
	Messages:hook("SuccesfulBuy", function(shop)
		shop.Label.BrickColor = BrickColor.new("Bright blue")
	end)
	for _, shop in pairs(CollectionService:GetTagged("Shop")) do
		prepareShop(shop)
	end
	refreshShopUnlocks()
	game:GetService("RunService").RenderStepped:connect(function()
		animateShopProps()
		manageShopUi()
		refreshShopUnlocks()
	end)
end

return Shops
