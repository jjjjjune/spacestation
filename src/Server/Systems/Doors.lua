local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local TeamData = import "Shared/Data/TeamData"

local DEBOUNCE_TIME = .5
local LOCKED_ICON = "rbxassetid://3484562953"
local UNLOCKED_ICON = "rbxassetid://3484563464"
local UNLOCK_TIME = 60 -- doors will automatically unlock after this amount of time

local debounceTable = {}
local lockTable = {}

local tweenInfo = TweenInfo.new(
	.4,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out,
	0
)

local function unlock(door)
	local lockedValue = door.LockedValue
	lockedValue.Value = false
	Messages:send("PlaySound","Unlock", door.Door.Position)
	door.Lock.Decal.Texture = UNLOCKED_ICON
	door.Lock.BrickColor = BrickColor.new("Medium blue")
	door.Lock.PointLight.Color = door.Lock.BrickColor.Color
	lockTable[door] = nil
end

local function lock(door)
	local lockedValue = door.LockedValue
	lockedValue.Value = true
	Messages:send("PlaySound","Lock", door.Door.Position)
	door.Lock.Decal.Texture = LOCKED_ICON
	door.Lock.BrickColor = BrickColor.new("Dusty Rose")
	door.Lock.PointLight.Color = door.Lock.BrickColor.Color
	lockTable[door] = time()
end

local function beep(door)
	Messages:send("PlaySound","Error", door.Door.Position)
	door.Open.BrickColor = BrickColor.new("Dusty Rose")
	door.OpenOutside.BrickColor = BrickColor.new("Dusty Rose")
	door.Open.PointLight.Color = door.Open.BrickColor.Color
	door.OpenOutside.PointLight.Color = door.OpenOutside.BrickColor.Color
	delay(.2, function()
		wait(.2)
		door.Open.BrickColor = BrickColor.new("Olivine")
		door.OpenOutside.BrickColor = BrickColor.new("Olivine")
		door.Open.PointLight.Color = door.Open.BrickColor.Color
		door.OpenOutside.PointLight.Color = door.OpenOutside.BrickColor.Color
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

local function countDoors(door)
	local n = 0
	for i, v in pairs(door:GetChildren()) do
		if v.Name == "Door" then
			n = n + 1
		end
	end
	return n
end

local function onOpened(door)
	for _, part in pairs(door:GetChildren()) do
		if part.Name == "Indicator" then
			part.BrickColor = BrickColor.new("Olivine")
		end
	end
end

local function onClosed(door)
	for _, part in pairs(door:GetChildren()) do
		if part.Name == "Indicator" then
			part.BrickColor = BrickColor.new("Terra Cotta")
		end
	end
end

local function close(door)
	if countDoors(door) == 1 then
		local tween = TweenService:Create(door.Door,tweenInfo, {CFrame = door.Door.CFrame * CFrame.new(0,-14.5,0)})
		tween:Play()
	else
		for _, d in pairs(door:GetChildren()) do
			if d.Name == "Door" then
				local tween = TweenService:Create(d,tweenInfo, {CFrame = d.CFrame * CFrame.new(-d.Size.X/2,0,0)})
				tween:Play()
			end
		end
	end
	Messages:send("PlaySound","Door", door.Door.Position)
	door.OpenValue.Value = false
	onClosed(door)
end

local function open(door)
	if countDoors(door) == 1  then
		local tween = TweenService:Create(door.Door,tweenInfo, {CFrame = door.Door.CFrame * CFrame.new(0,14.5,0)})
		tween:Play()
	else
		for _, d in pairs(door:GetChildren()) do
			if d.Name == "Door" then
				local tween = TweenService:Create(d,tweenInfo, {CFrame = d.CFrame * CFrame.new(d.Size.X/2,0,0)})
				tween:Play()
			end
		end
	end
	Messages:send("PlaySound","Door", door.Door.Position)
	door.OpenValue.Value = true
	onOpened(door)
end

local function canUnlockDoor(door, tool, player)
	local neededAccess = "Generic"
	if door:FindFirstChild("Access") then
		neededAccess = door.Access.Value
	end
	local team = tool.Team.Value
	if team ~= "" then -- first we check the keycard they tried this with
		local accessTable = TeamData[team].access
		for _, accessType in pairs(accessTable) do
			if accessType == neededAccess then
				return true
			end
		end
	end
	team = player.Team.Name
	local accessTable = TeamData[team].access
	for _, accessType in pairs(accessTable) do
		if accessType == neededAccess then
			return true
		end
	end
	for _, ownedTool in pairs(player.Backpack:GetChildren()) do -- then we check their whole inventory
		if ownedTool:FindFirstChild("Team") then
			local team = ownedTool.Team.Value
			if team.Value ~= "" then
				print("TEEEAAAAM",team, type(team))
				local accessTable = TeamData[team].access
				for _, accessType in pairs(accessTable) do
					if accessType == neededAccess then
						return true
					end
				end
			end
		end
	end
	return false
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
	door.PrimaryPart = door.Door

	local function attemptOpen(player)
		local tool = player.Backpack:FindFirstChild("Keycard")
		if not tool then
			tool = player.Character.Keycard
		end
		if not canUnlockDoor(door, tool, player) then -- player needs keycard access
			beep(door)
			Messages:sendClient(player, "Notify", "You need "..door.Access.Value.." access!")
			return
		end
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
			unlock(door)
		else
			lock(door)
		end
	end

	Messages:send("RegisterDetector", openDetector, function(player)
		attemptOpen(player)
	end)
	Messages:send("RegisterDetector", openOutsideDetector, function(player)
		attemptOpen(player)
	end)
	Messages:send("RegisterDetector", lockDetector, function(player)
		lockUnlock(player)
	end)

	if door:FindFirstChild("Forcefield") then
		PhysicsService:SetPartCollisionGroup(door.Forcefield, "Fake")
	end
end

local Doors = {}

function Doors:start()
	for _, door in pairs(CollectionService:GetTagged("Door")) do
		prepareDoor(door)
	end
	Messages:hook("OpenAllDoors", function(noValue)
		if noValue then
			noValue:Kick()
		end
		for _, door in pairs(CollectionService:GetTagged("Door")) do
			Messages:send("ForceOpenDoor",door)
		end
	end)
	Messages:hook("ForceOpenDoor", function(door)
		unlock(door)
		if door.OpenValue.Value == false then
			open(door)
		end
	end)
	Messages:hook("UnlockDoor", function(door, tool) -- this is actually just opening the door
		local player = game.Players:GetPlayerFromCharacter(tool.Parent)
		if canUnlockDoor(door, tool, player) then
			if door.OpenValue.Value == false then
				open(door)
			end
		else
			beep(door)
			Messages:sendClient(player, "Notify", "You need "..door.Access.Value.." access!")
		end
	end)
	game:GetService("RunService").Stepped:connect(function()
		for door, t in pairs(lockTable) do
			if time() - t > UNLOCK_TIME then
				unlock(door)
				lockTable[door] = nil
			end
		end
	end)
end

return Doors
