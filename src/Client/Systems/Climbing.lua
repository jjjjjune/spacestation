local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local GetTotalStaminaTime = import "Shared/Utils/GetTotalStaminaTime"
local CollectionService = game:GetService("CollectionService")

local climbGyro
local climbPos
local climbAnimPlaying = false
local moveAnimPlaying = false
local climbing = false
local moving = false

local keyDownMap = {}
local MOVE_SPEED = 3
local stamina = 100
local lastStamina = time()

local function getMoveDir()
	local checkDir = CFrame.new()
	local moveDir = CFrame.new()
	if keyDownMap[Enum.KeyCode.W] then
		moveDir = moveDir * CFrame.new(0,1*MOVE_SPEED,0)
	end
	if keyDownMap[Enum.KeyCode.S] then
		moveDir = moveDir * CFrame.new(0,-1*MOVE_SPEED,0)
	end
	if keyDownMap[Enum.KeyCode.A] then
		moveDir = moveDir * CFrame.new(-1*MOVE_SPEED,0,0)
		checkDir = checkDir * CFrame.new(-1*MOVE_SPEED,0,0)
	end
	if keyDownMap[Enum.KeyCode.D] then
		moveDir = moveDir * CFrame.new(1*MOVE_SPEED,0,0)
		checkDir = checkDir * CFrame.new(1*MOVE_SPEED,0,0)
	end
	if moveDir.p.magnitude > 0 then
		moving = true
	else
		moving = false
	end
	return moveDir, checkDir
end

local function drawPoint(pos, color, t)
	local ball = Instance.new("Part", player.Character)
	ball.Size = Vector3.new(.5,.5,.5)
	ball.Material = Enum.Material.SmoothPlastic
	ball.Anchored = true
	ball.CFrame = CFrame.new(pos)
	ball.BrickColor = color
	game:GetService("Debris"):AddItem(ball, t or .2)
end

local function drawRay(a,b)
	local part = Instance.new("Part")
	part.Name = "DebugLine"
	part.Size = Vector3.new(0.05, 0.05, 0.05)
	part.CanCollide = false
	part.Anchored = true
	part.Transparency = 1

	local beam = Instance.new("Beam")
	beam.LightInfluence = 0
	beam.FaceCamera = true
	beam.Width0 = 0.8
	beam.Width1 = 0.1
	beam.Color = ColorSequence.new(Color3.new(0, 1, 1), Color3.new(1, 1, 1))
	beam.Parent = part

	local copy = part:Clone()
	copy.CFrame = CFrame.new(a)
	copy.Parent = container or workspace
	local attA = Instance.new("Attachment")
	attA.Parent = copy
	local attB = Instance.new("Attachment")
	attB.CFrame = CFrame.new(b - a)
	attB.Parent = copy

	copy.Beam.Attachment0 = attA
	copy.Beam.Attachment1 = attB

	if color then
		copy.Beam.Color = color
	end
end

local function canClimb(dir)
	if player.Character and CollectionService:HasTag(player.Character, "Ragdolled") then
		return false
	end
	if stamina == 0 then
		return false
	end
	local character = player.Character
	local hrp = character.HumanoidRootPart
	local originCF = hrp.CFrame * CFrame.new(0,0, -hrp.Size.Z/2)
	local length = 3

	-- front ray
	local checkRay = Ray.new(originCF.p, hrp.CFrame.lookVector.unit * length)
	local hit, pos, normal = workspace:FindPartOnRayWithIgnoreList(checkRay, {character})
	if hit then
		return hit, normal, pos
	end

	-- ray in movement direction
	local translated1 = hrp.CFrame * CFrame.new(0,0,-2)
	local origin = translated1
	local direction = CFrame.new(origin.p, (origin * dir).p)
	checkRay = Ray.new(origin.p, direction.lookVector.unit * -(length+1))

	hit, pos, normal = workspace:FindPartOnRayWithIgnoreList(checkRay, {character})

	--[[drawRay(origin.p, pos)
	drawPoint(pos, BrickColor.new("Really red"),200)
	drawPoint(origin.p, BrickColor.new("Teal"),200)--]]

	if hit then
		return hit, normal, pos
	end

	--[[drawPoint(pos1, BrickColor.new("White"), 20)
	drawPoint(pos2, BrickColor.new("White"), 20)--]]
end

local function onEndClimb()
	local character = player.Character
	if climbGyro and climbPos then
		climbGyro.MaxTorque = Vector3.new()
		climbPos.MaxForce = Vector3.new()
		climbPos.Position = character.HumanoidRootPart.Position
	end
end

local function ledgeCheck()
	local character = player.Character
	local hrp = character.HumanoidRootPart
	local cf = hrp.CFrame * CFrame.new(0,1, -2)
	local ledgeRay = Ray.new(cf.p, Vector3.new(0,-2,0))
	local hit, pos = workspace:FindPartOnRay(ledgeRay, character)
	if hit then
		return true
	end
end

local function doClimbMovement()
	local character = player.Character
	local hrp = character.HumanoidRootPart
	local moveDir, checkDir = getMoveDir()
	local hit, normal, pos = canClimb(checkDir)
	if not normal then
		if ledgeCheck() then
			climbPos.MaxForce = Vector3.new()
			climbGyro.MaxTorque = Vector3.new()
			character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		climbing = false
		return
	else
		local origin = pos
		local normalCF = CFrame.new(origin+normal, origin)
		climbGyro.CFrame = normalCF
	end
	local relativeCF = (climbGyro.CFrame * CFrame.new(0,0,(hrp.Size.Z/2) + .5))
	climbPos.Position = (relativeCF * moveDir).p
end

local function climbTick()
	local character = player.Character
	if (climbing) and (not climbAnimPlaying) then
		character.Humanoid.AutoRotate = false
		Messages:send("PlayAnimationClient", "ClimbBase")
		climbAnimPlaying = true
	elseif (not climbing) and (climbAnimPlaying) then
		character.Humanoid.AutoRotate = true
		Messages:send("StopAnimationClient", "ClimbBase")
		climbAnimPlaying = false
	end
	if moving and climbing then
		if not moveAnimPlaying then
			Messages:send("PlayAnimationClient", "ClimbUpDown")
			moveAnimPlaying = true
		end
	else
		if moveAnimPlaying then
			Messages:send("StopAnimationClient", "ClimbUpDown")
			moveAnimPlaying = false
		end
	end
	if climbing and climbGyro then
		climbGyro.MaxTorque = Vector3.new(40000000,4000000000,40000000)
		climbPos.MaxForce = Vector3.new(40000,40000,40000)
		doClimbMovement()
	else
		if moveAnimPlaying then
			Messages:send("StopAnimationClient", "ClimbUpDown")
			moveAnimPlaying = false
		end
		onEndClimb()
	end
end

local function staminaTick()
	local tickTime = GetTotalStaminaTime(_G.Data["race"])/100
	if climbing then
		if time() - lastStamina > tickTime then
			lastStamina = time()
			stamina = math.max(0, stamina - 1)
		end
	else
		if time() - lastStamina > tickTime then
			lastStamina = time()
			stamina = math.min(100, stamina + .5)
		end
	end
	if stamina < 100 then
		Messages:send("SetLastClimb", time()-6)
	end
	Messages:send("SetStamina", stamina)
end

local Climbing = {}

function Climbing:start()
	UserInputService.InputBegan:connect(function(inputObject, gameProcessed)
		if not gameProcessed then
			keyDownMap[inputObject.KeyCode] = true
			if inputObject.KeyCode == Enum.KeyCode.Space then
				if climbing then
					climbing = false
					return
				end
				local humanoid = player.Character.Humanoid
				if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
					local moveDir, checkDir = getMoveDir()
					if canClimb(moveDir, checkDir) then
						climbing = true
					else
						if ledgeCheck() then
							climbPos.MaxForce = Vector3.new()
							climbGyro.MaxTorque = Vector3.new()
							humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
						end
					end
				end
			end

		end
	end)
	UserInputService.InputEnded:connect(function(inputObject, gameProcessed)
		if not gameProcessed then
			keyDownMap[inputObject.KeyCode] = false
		end
	end)
	player.CharacterAdded:connect(function(character)
		climbAnimPlaying = false
		character:WaitForChild("HumanoidRootPart")
		character.HumanoidRootPart:WaitForChild("ClimbPos")
		character.HumanoidRootPart:WaitForChild("ClimbGyro")
		climbPos = character.HumanoidRootPart.ClimbPos
		climbGyro =character.HumanoidRootPart.ClimbGyro
		stamina = 100
	end)
	game:GetService("RunService").RenderStepped:connect(function()
		climbTick()
		staminaTick()
	end)
end

return Climbing
