local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")

local seconds = 0

local day = 60*60*24

local function getTimeString(timeRemaining)
	local hours = math.floor(timeRemaining/3600)
	local minutes = math.floor((timeRemaining - (hours * 3600))/60)
	local hoursString = hours..""
	local minutesString = minutes..""

	if hours < 10 then
		hoursString = "0"..hoursString
		if hours == 0 then
			hoursString = "0"
		end
	end
	if minutes < 10 and hours ~= 0 then
		minutesString = "0"..minutesString
		if minutes == 0 then
			minutesString = "0"
		end
	end
	-- button.Item.Value.."\n"..
	local str =hoursString..":"..minutesString
	return str
end

local function onNewDay()
	Messages:send("PayAll")
end

local function displayTime()
	for _, clock in pairs(CollectionService:GetTagged("Clock")) do
		clock.Display.SurfaceGui.TextLabel.Text = getTimeString(seconds)
	end
end

local Clocks = {}

function Clocks:start()
	game:GetService("RunService").Heartbeat:connect(function()
		seconds = seconds + 2.5
		if seconds > day then
			seconds= 0
			onNewDay()
		end
		displayTime()
	end)
end

return Clocks
