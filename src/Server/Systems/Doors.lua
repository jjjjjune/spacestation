local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(
	.4,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out,
	0
)


local function beep(door)

end

local function close(door)
	local tween = TweenService:Create(door.Door,tweenInfo, {CFrame = door.Door.CFrame * CFrame.new(0,-14,0)})
	tween:Play()
	Messages:send("PlaySound","Door", door.Door.Position)
	door.OpenValue.Value = false
end

local function open(door)
	local tween = TweenService:Create(door.Door,tweenInfo, {CFrame = door.Door.CFrame * CFrame.new(0,14,0)})
	tween:Play()
	Messages:send("PlaySound","Door", door.Door.Position)
	door.OpenValue.Value = true
end

local function prepareDoor(door)
	local openButton = door:WaitForChild("Open")
	local openOutsideButton = door:WaitForChild("OpenOutside")
	local lockButton = door:WaitForChild("Lock")
	local openDetector = Instance.new("ClickDetector", openButton)
	local openOutsideDetector = Instance.new("ClickDetector", openOutsideButton)
	local lockDetector = Instance.new("ClickDetector",lockButton)
	local lockedValue = Instance.new("BoolValue", door)
	lockedValue.Name = "LockedValue"
	lockedValue.Value = false
	local openValue = Instance.new("BoolValue", door)
	openValue.Name = "OpenValue"
	openValue.Value = false

	local function attemptOpen(player)
		local isLocked = lockedValue.Value == true
		local isOpen = openValue.Value == true
		if not isLocked then
			if isOpen then
				close(door)
			else
				open(door)
			end
		else
			beep(door)
		end
	end

	openDetector.MouseClick:connect(function(player)
		attemptOpen(player)
	end)
	openOutsideDetector.MouseClick:connect(function(player)
		attemptOpen(player)
	end)
end

local Doors = {}

function Doors:start()
	for _, door in pairs(CollectionService:GetTagged("Door")) do
		prepareDoor(door)
	end
end

return Doors
