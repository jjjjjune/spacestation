local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local RunService = game:GetService("RunService")
local root
local flying = false
local UserInputService = game:GetService("UserInputService")

local swimPlaying = false
local idlePlaying = false
local zeroGravity = false
local sprinting = false
local playerStats = {}

local FALL = .4

local Controller = {}

local function handleFlyingAnimations(moveDir)
	if moveDir.magnitude == 0 then
		if not idlePlaying then
			Messages:send("PlayAnimationClient", "Idle")
			idlePlaying = true
		end
		if swimPlaying == true then
			Messages:send("StopAnimationClient", "Swim")
			swimPlaying = false
		end
	else
		if not swimPlaying then
			Messages:send("PlayAnimationClient", "Swim")
			swimPlaying = true
		end
		if idlePlaying == true then
			Messages:send("StopAnimationClient", "Idle")
			idlePlaying = false
		end
	end
end

local function determineWalkspeed(base, hunger)
	local speed = math.max(16, base + (hunger - 25)/5)
	return speed
end

function Controller:start()
	local player = game.Players.LocalPlayer
	RunService.RenderStepped:connect(function()
		local hunger = (playerStats[2] and playerStats[2].current) or 0
		if not root then
			root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		end
		if root and root.Parent ~= nil and root.Parent:FindFirstChild("Humanoid") then
			if sprinting then
				root.Parent.Humanoid.WalkSpeed = determineWalkspeed(28, hunger)
			else
				root.Parent.Humanoid.WalkSpeed = determineWalkspeed(16, hunger)
			end
			if zeroGravity then
				workspace.Gravity = 1
			else
				workspace.Gravity = 40
			end
		else
			if root and root.Parent == nil then
				root = nil
			end
		end
	end)
	player.CharacterAdded:connect(function(character)
		root = character:WaitForChild("HumanoidRootPart")
		local flyPos = root:WaitForChild("FlyPosition")
		local flyGyro = root:WaitForChild("FlyGyro")
		local connect
		connect = RunService.RenderStepped:connect(function()
			debug.profilebegin("controller")
			if flying then
				flyPos.MaxForce = Vector3.new(0,20000,0)
				--flyPos.Position = Vector3.new(0, flyPos.Position.Y-FALL, 0)
				flyGyro.MaxTorque = Vector3.new(20000,20000,20000)
				flyGyro.CFrame = workspace.CurrentCamera.CFrame * CFrame.Angles(-math.pi/2,0,0)
				local moveDir = root.Parent.Humanoid.MoveDirection
				local speed = 20
				root.Velocity = moveDir * speed
				handleFlyingAnimations(moveDir)
				local r = Ray.new(root.Position, Vector3.new(0,-300,0))
				local hit, pos = workspace:FindPartOnRay(r,root.Parent)
				local dist = (pos - root.Position).magnitude

				if hit then
					flyPos.Position = flyPos.Position - Vector3.new(0,.25 + (300 - dist)/200,0)
				end
			else
				Messages:send("StopAnimationClient", "Idle")
				Messages:send("StopAnimationClient", "Swim")
				flyPos.MaxForce = Vector3.new()
				flyGyro.MaxTorque = Vector3.new()
			end
			if character.Parent==nil then
				connect:disconnect()
			end
			debug.profileend()
		end)
	end)
	UserInputService.JumpRequest:connect(function()
		local character = player.Character
		local flyPos = character.HumanoidRootPart.FlyPosition
		flyPos.Position = flyPos.Position + Vector3.new(0,4,0)
	end)
	Messages:hook("ToggleSprint", function()
		sprinting = not sprinting
	end)
	Messages:hook("ToggleGravity", function()
		zeroGravity = not zeroGravity
	end)
	Messages:hook("UpdateStats", function(stats)
		playerStats = stats
	end)
end

return Controller
