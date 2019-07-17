local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local DEBOUNCE_TIME = .5
local LOCKED_ICON = "rbxassetid://3484562953"
local UNLOCKED_ICON = "rbxassetid://3484563464"

local debounceTable = {}

local tweenInfo = TweenInfo.new(
	.4,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out,
	0
)

local function beep(door)
	Messages:send("PlaySound","Error", door.Door.Position)
	door.Open.BrickColor = BrickColor.new("Dusty Rose")
	door.OpenOutside.BrickColor = BrickColor.new("Dusty Rose")
	spawn(function()
		wait(.2)
		door.Open.BrickColor = BrickColor.new("Shamrock")
		door.OpenOutside.BrickColor = BrickColor.new("Shamrock")
	end)
end

local function debounced(door)
	if time() - (debounceTable[door] or 0) < DEBOUNCE_TIME then
		return true
	else
		debounceTable[door] = time()
		return false
	end
end

local function close(door)
	local tween = TweenService:Create(door.Door,tweenInfo, {CFrame = door.Door.CFrame * CFrame.new(0,-14.5,0)})
	tween:Play()
	Messages:send("PlaySound","Door", door.Door.Position)
	door.OpenValue.Value = false
end

local function open(door)
	local tween = TweenService:Create(door.Door,tweenInfo, {CFrame = door.Door.CFrame * CFrame.new(0,14.5,0)})
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
		if not debounced(door) then
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
	end

	local function lockUnlock(player)
		local isLocked = lockedValue.Value == true
		if isLocked then
			lockedValue.Value = false
			Messages:send("PlaySound","Unlock", door.Door.Position)
			door.Lock.Decal.Texture = UNLOCKED_ICON
			door.Lock.BrickColor = BrickColor.new("Bright blue")
		else
			lockedValue.Value = true
			Messages:send("PlaySound","Lock", door.Door.Position)
			door.Lock.Decal.Texture = LOCKED_ICON
			door.Lock.BrickColor = BrickColor.new("Dusty Rose")
		end
	end

	openDetector.MouseClick:connect(function(player)
		attemptOpen(player)
	end)
	openOutsideDetector.MouseClick:connect(function(player)
		attemptOpen(player)
	end)
	lockDetector.MouseClick:connect(function(player)
		lockUnlock(player)
	end)
end

local Doors = {}

function Doors:start()
	for _, door in pairs(CollectionService:GetTagged("Door")) do
		prepareDoor(door)
	end
end

return Doors
