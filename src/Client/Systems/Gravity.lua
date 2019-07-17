local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local RunService = game:GetService("RunService")
local root
local flying = false
local UserInputService = game:GetService("UserInputService")

local swimPlaying = false
local idlePlaying = false

local FALL = .4

local Gravity = {}

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

function Gravity:start()
	local player = game.Players.LocalPlayer
	RunService.RenderStepped:connect(function()
		if root and root.Parent ~= nil then
			local r = Ray.new(root.Position, Vector3.new(0,-20,0))
			local hit, pos = workspace:FindPartOnRay(r, root.Parent)
			if not hit then
				flying = true
				workspace.Gravity = 0
				local humanoid = root.Parent:FindFirstChild("Humanoid")
				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				end
			else
				root.FlyPosition.Position = root.Position
				flying = false
				workspace.Gravity = 40
				local humanoid = root.Parent:FindFirstChild("Humanoid")
				if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Physics then
					humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end
			end
		else
			if root and root.Parent == nil then
				root = nil
				-- garbage collect baby
			end
		end
	end)
	player.CharacterAdded:connect(function(character)
		root = character:WaitForChild("HumanoidRootPart")
		local flyPos = root:WaitForChild("FlyPosition")
		local flyGyro = root:WaitForChild("FlyGyro")
		local connect
		connect = RunService.RenderStepped:connect(function()
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
		end)
	end)
	UserInputService.JumpRequest:connect(function()
		local character = player.Character
		local flyPos = character.HumanoidRootPart.FlyPosition
		flyPos.Position = flyPos.Position + Vector3.new(0,4,0)
	end)
end

return Gravity
