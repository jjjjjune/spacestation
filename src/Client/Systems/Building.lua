local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local WorldConstants = import "Shared/Data/WorldConstants"
local UserInputService = game:GetService("UserInputService")
local BuildData = import "Shared/Data/BuildData"
local CollectionService = game:GetService("CollectionService")

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local buildingPlacing = nil--"Raft"
local buildingPlacingModel = nil
local rotation = 0
local buildRange = 40

local function setProperty(model, property, value)
	for _, p in pairs(model:GetChildren()) do
		if p:IsA("BasePart") then
			local status, err = pcall(function() p[property] = value end)
		end
	end
end

local function getCharacterPosition()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		return player.Character.HumanoidRootPart.Position
	end
	return Vector3.new()
end

local function getPlacementPosition()
	local pos = mouse.Hit.p
	pos = Vector3.new(math.ceil(pos.X), math.max(pos.Y, WorldConstants.WATER_LEVEL),math.ceil(pos.Z))
	return pos
end

local function canPlace()
	local target = mouse.Target
	local pos = getPlacementPosition()
	local origin = getCharacterPosition()
	local data = BuildData[buildingPlacing]
	if not data then
		return
	end
	if (pos - origin).magnitude > buildRange then
		return false
	end
	if data.water then
		if target ~= workspace.terrain then
			return false
		end
	else
		if target == workspace.terrain then
			return false
		end
	end
	return true
end

local function manageBuildingPlacement()
	if not buildingPlacing then
		return
	end
	if not buildingPlacingModel then
		buildingPlacingModel = import("Assets/Buildings/"..buildingPlacing):Clone()
		buildingPlacingModel.PrimaryPart = buildingPlacingModel.Base
	end
	buildingPlacingModel.Parent = workspace
	setProperty(buildingPlacingModel, "Anchored", true)
	setProperty(buildingPlacingModel, "CanCollide", false)
	setProperty(buildingPlacingModel, "Transparency", .5)
	setProperty(buildingPlacingModel, "Disabled", true)
	--setProperty(buildingPlacingModel, "Material", Enum.Material.ForceField)
	if canPlace() then
		setProperty(buildingPlacingModel, "BrickColor", BrickColor.new("Bright green"))
	else
		setProperty(buildingPlacingModel, "BrickColor", BrickColor.new("Bright red"))
	end
	mouse.TargetFilter = buildingPlacingModel
	local pos = getPlacementPosition()
	local mouseCF = CFrame.new(pos)
	mouseCF = mouseCF * CFrame.new(0, buildingPlacingModel.Base.Size.Y/2,0)
	mouseCF = mouseCF* CFrame.Angles(0, math.rad(rotation),0)
	if mouse.Target and mouse.Target.Name == buildingPlacingModel.Name.."Point" then
		mouseCF = mouse.Target.CFrame
	end
	buildingPlacingModel:SetPrimaryPartCFrame(mouseCF)
end

local function cancelBuilding()
	buildingPlacing = nil
	if buildingPlacingModel then
		buildingPlacingModel:Destroy()
		buildingPlacingModel = nil
	end
	Messages:send("SetBlueprint", nil)
end

local function place()
	local placementCF = buildingPlacingModel.PrimaryPart.CFrame
	Messages:sendServer("PlaceSchematic", buildingPlacing, placementCF)
	cancelBuilding()
end

local Building = {}

function Building:start()
	UserInputService.InputBegan:connect(function(inputObject, gameProcessed)
		if not gameProcessed then
			if inputObject.KeyCode == Enum.KeyCode.R then
				rotation = rotation + 45
			end
		end
	end)
	UserInputService.InputBegan:connect(function(inputObject, gameProcessed)
		if not gameProcessed then
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				if buildingPlacing then
					if canPlace() then
						place()
					else
						cancelBuilding()
					end
				end
			end
		end
	end)
	game:GetService("RunService").RenderStepped:connect(function()
		manageBuildingPlacement()
	end)
	Messages:hook("Died", function()
		cancelBuilding()
	end)
	Messages:hook("SetBuildingPlacing", function(buildingName)
		if buildingPlacingModel then
			buildingPlacingModel:Destroy()
			buildingPlacingModel = nil
		end
		buildingPlacing = buildingName
	end)
end

return Building
