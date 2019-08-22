local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")

local lastOrderedTable = {}
local erroring = {}
local lastColors = {}

local function error(button)
	if not lastColors[button] then
		lastColors[button] = button.BrickColor
	end
	if not erroring[button] then
		erroring[button]= true
		spawn(function()
			Messages:send("PlaySound","Error", button.Position)
			button.BrickColor = BrickColor.new("Dusty Rose")
			delay(.2, function()
				button.BrickColor = lastColors[button]
				erroring[button] = false
			end)
		end)
	end
end

local function order(button)
	Messages:send("PlaySound","ButtonNew", button.Position)
	lastOrderedTable[button] = time()
	Messages:send("MakeShip", button.Item.Value)
end

local function hook(button)
	Messages:send("RegisterDetector", button.ClickDetector, function(player)
		if not lastOrderedTable[button] then
			order(button)
		else
			if time() - lastOrderedTable[button] < button.Debounce.Value then
				error(button)
			else
				order(button)
			end
		end
	end)
end

local function showTimeRemaining(button, timeRemaining)
	local hours = math.floor(timeRemaining/3600)
	local minutes = math.floor((timeRemaining - (hours * 3600))/60)
	local seconds = math.floor(timeRemaining - (minutes*60) - (hours * 3600))
	local hoursString = hours..""
	local minutesString = minutes..""
	local secondsString = seconds..""

	if hours < 10 then
		hoursString = "0"..hoursString
		if hours == 0 then
			hoursString = ""
		end
	end
	if minutes < 10 and hours ~= 0 then
		minutesString = "0"..minutesString
		if minutes == 0 then
			minutesString = "0"
		end
	end
	if seconds < 10 and minutes ~= 0 then
		secondsString = "0"..secondsString
	end
	-- button.Item.Value.."\n"..
	local str =minutesString..":"..secondsString
	button.SurfaceGui.TextLabel.Text = str
end

local hiddenDetectors = {}

local function showDetector(button)
	if hiddenDetectors[button] then
		local detector = hiddenDetectors[button]
		if detector.Parent ~= button then
			hiddenDetectors[button].Parent = button
		end
	end
end

local function hideDetector(button)
	if not hiddenDetectors[button] then
		hiddenDetectors[button] = button.ClickDetector
	end
	if hiddenDetectors[button].Parent ~= nil then
		hiddenDetectors[button].Parent = nil
	end
end

local function update(button)
	if not lastOrderedTable[button] then
		button.SurfaceGui.ImageLabel.Visible = true
		button.SurfaceGui.TextLabel.Visible = false
		showDetector(button)
	else
		local timeSoFar = time() - lastOrderedTable[button]
		if timeSoFar < button.Debounce.Value then
			button.SurfaceGui.ImageLabel.Visible = false
			button.SurfaceGui.TextLabel.Visible = true
			showTimeRemaining(button, button.Debounce.Value - timeSoFar)
			hideDetector(button)
			--button.Material = Enum.Material.SmoothPlastic
		else
			button.SurfaceGui.ImageLabel.Visible = true
			button.SurfaceGui.TextLabel.Visible = false
			--button.Material = Enum.Material.Neon
			showDetector(button)
		end
	end
end

local function updateOrderConsoles()
	for _, console in pairs(CollectionService:GetTagged("OrderConsole")) do
		for _, button in pairs(console:GetChildren()) do
			if button.Name == "Button" then
				update(button)
			end
		end
	end
end

local function hookConsoles()
	for _, console in pairs(CollectionService:GetTagged("OrderConsole")) do
		for _, button in pairs(console:GetChildren()) do
			if button.Name == "Button" then
				hook(button)
			end
		end
	end
end

local CargoOrdering = {}

function CargoOrdering:start()
	hookConsoles()
	game:GetService("RunService").Stepped:connect(function()
		debug.profilebegin("orderconsoles")
		updateOrderConsoles()
		debug.profileend()
	end)
end

return CargoOrdering
