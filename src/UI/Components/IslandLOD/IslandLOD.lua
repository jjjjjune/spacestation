local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })

local StyleConstants = import "Shared/Data/StyleConstants"
local WorldConstants = import "Shared/Data/WorldConstants"
local Settings = UserSettings():GetService("UserGameSettings")
local DangerIndicator = Roact.PureComponent:extend("DangerIndicator")

local camera = workspace.CurrentCamera
local offset = Vector3.new(0,0,-1000)
local islands = {}

local function isWithin(pos, model)
	local headPos = pos
	local barrierPos = model:GetModelCFrame()
	local size = model:GetModelSize()
	local barrierCorner1 = barrierPos * CFrame.new(-(size.X)/2,0,-(size.Z)/2)
	local barrierCorner2 = barrierPos * CFrame.new((size.X)/2,0,(size.Z)/2)
	local x1, y1, x2, y2 = barrierCorner1.X, barrierCorner1.Z, barrierCorner2.X, barrierCorner2.Z
	if headPos.X > x1 and headPos.X < x2 then
		if headPos.Z > y1 and headPos.Z < y2 then
			return true
		end
	end
	return false
end

function DangerIndicator:init()
	self.visible = false
	self.frameRef = Roact.createRef()
	self.billboardRef = Roact.createRef()
	game:GetService("RunService").RenderStepped:connect(function()
		if not self.billboardRef.current then
			print("no bilklboard")
			return
		end

		if Settings.SavedQualityLevel.Value < 7 then
			self:setState(function(state)
				return {
					shouldShow = true,
				}
			end)
		else
			self:setState(function(state)
				return {
					shouldShow = false,
				}
			end)
		end

		if not self.part then
			self.part = Instance.new("Part")
			self.part.Anchored = true
			self.part.Transparency = 1
			self.part.Parent = game.Players.LocalPlayer.PlayerGui
		end

		local currentCamera = workspace.CurrentCamera
		local billboard = self.billboardRef.current
		billboard.Size = UDim2.new(0,currentCamera.ViewportSize.X,0, currentCamera.ViewportSize.Y)
		billboard.Adornee = self.part
		billboard.MaxDistance = 10000

		self.frameRef.current.BackgroundColor3 = workspace["Egg Mesh"].Color
		self.frameRef.current.Ambient = game.Lighting.Ambient
		self.frameRef.LightDirection = game.Lighting:GetSunDirection()

		self.part.CFrame = workspace.CurrentCamera.CFrame

		local player = game.Players.LocalPlayer
		local character = player.Character
		if character then
			if character:FindFirstChild("Head") then
				for _, isle in pairs(islands) do
					if isle:IsA("BasePart") then
						isle.Color = workspace.Terrain.WaterColor
						if isle.Name == "water" then
							isle.Parent = workspace
						end
						isle.CFrame = CFrame.new(Vector3.new(camera.CFrame.p.X, 9, camera.CFrame.p.Z))
					end
				end
			end
		end

		if #islands == 0 and (self.state.shouldShow == true) then
			if self.frameRef.current then
				local viewportFrame = self.frameRef.current
				local islandsFolder = game.ReplicatedStorage.IslandPreviews
				for _, isle in pairs(islandsFolder:GetChildren()) do
					isle = isle:Clone()
					isle.Parent = viewportFrame
					table.insert(islands, isle)
				end
			end
		elseif #islands > 0 and (self.state.shouldShow == false) then
			for i, isle in pairs(islands) do
				isle:Destroy()
				islands[i] = nil
			end
		end
	end)
	self:setState(function(state)
		return {
			shouldShow = false,
		}
	end)
end

function DangerIndicator:render()
	return Roact.createElement("BillboardGui", {
		[Roact.Ref] = self.billboardRef,
		StudsOffset = offset,
	}, {
		Frame = Roact.createElement("ViewportFrame", {
			AnchorPoint = Vector2.new(0,0),
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			BackgroundTransparency =0,
			Visible = self.state.shouldShow,
			CurrentCamera = camera,
			[Roact.Ref] = self.frameRef
		})
	})
end

function DangerIndicator:didMount()

end

function DangerIndicator:didUpdate()

end

local function mapStateToProps(state, props)
	return {
	}
end

return Connect(mapStateToProps)(DangerIndicator)

