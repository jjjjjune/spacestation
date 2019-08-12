local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local DEBOUNCE_TIME = .5

local debounceTable = {}

local function turnOn(player, door)
	if door:FindFirstChild("FixPercent") then
		return
	end
	Messages:send("PlaySound","Button", door.OnOff.Position)
	door.OnValue.Value = true
	door.OnOff.BrickColor = BrickColor.new("Shamrock")
	door.OnOff.PointLight.Color = door.OnOff.BrickColor.Color
	for _, light in pairs(CollectionService:GetTagged("Light")) do
		light.CastShadow = false
		for _, v in pairs(light:GetChildren()) do
			if string.find(v.Name, "Light") then
				light.BrickColor = BrickColor.new("White")
				v.Enabled = true
			end
		end
	end
	game.Lighting.Ambient = Color3.fromRGB(105,109,139)
	game.Lighting.Brightness = 2
	game.Lighting.OutdoorAmbient = Color3.fromRGB(96,73,136)
end

local function turnOff(player, door)
	if door:FindFirstChild("FixPercent") then
		return
	end
	Messages:send("PlaySound","Button",  door.OnOff.Position)
	door.OnValue.Value = false
	door.OnOff.BrickColor = BrickColor.new("Dusty Rose")
	door.OnOff.PointLight.Color = door.OnOff.BrickColor.Color
	for _, light in pairs(CollectionService:GetTagged("Light")) do
		light.CastShadow = true
		for _, v in pairs(light:GetChildren()) do
			if string.find(v.Name, "Light") then
				v.Enabled = false
				light.BrickColor = BrickColor.new("Black")
			end
		end
	end
	game.Lighting.Ambient = Color3.fromRGB(10,10,15)
	game.Lighting.Brightness = 0
	game.Lighting.OutdoorAmbient = Color3.fromRGB(10,10,15)
end

local function debounced(door)
	if time() - (debounceTable[door] or 0) < DEBOUNCE_TIME then
		return true
	else
		debounceTable[door] = time()
		return false
	end
end

local function prepareDoor(door)
	local switch = door:WaitForChild("OnOff")
	local onOffDetector = Instance.new("ClickDetector", switch)
	local onValue = Instance.new("BoolValue", door)
	onValue.Name = "OnValue"
	onValue.Value = true

	local function attemptOpen(player)
		if not debounced(door) then
			local isOn= onValue.Value == true
			if not isOn then
				turnOn(player, door)
			else
				turnOff(player, door)
			end
		end
	end

	Messages:send("RegisterDetector", onOffDetector, function(player)
		attemptOpen(player)
	end)
end

local Switches = {}

function Switches:start()
	for _, door in pairs(CollectionService:GetTagged("LightSwitch")) do
		prepareDoor(door)
	end
end

return Switches
