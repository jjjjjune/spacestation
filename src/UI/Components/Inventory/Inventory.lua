local import = require(game.ReplicatedStorage.Shared.Import)

local Roact = import "Roact"
local Connect = import("RoactRodux", { "connect" })
local Replicate, ReplicateToServer = import("Shared/State/Replication", { "replicate", "replicateToServer" })
local IconsForSlots = import "../IconsForSlots"
local Store = import "Shared/State/Store"
local RemoveItem = import "Shared/Actions/Inventories/RemoveItem"
local SetItemPosition = import "Shared/Actions/Inventories/SetItemPosition"
local Messages = import "Shared/Utils/Messages"
local StyleConstants = import "Shared/Data/StyleConstants"
local GetInventorySize = import "Shared/Utils/GetInventorySize"

local Inventory = Roact.PureComponent:extend("Inventory")

local UserInputService = game:GetService("UserInputService")

local currentCamera = workspace.CurrentCamera

local lastClickedTable = {}

local function isPointWithinBox(point, box)
    local x, y = point.X, point.Y
    local left = box.AbsolutePosition
    local right = left + box.AbsoluteSize
    return (x >= left.X and x <= right.X) and (y >= left.Y and y <= right.Y)
end

function Inventory:getGridSizeX()
	local containerInstance = self.itemFrameRef.current
	if containerInstance then
		local padding = 24
		local inventorySize = GetInventorySize(game.Players.LocalPlayer)
		local maxPerRow = math.max(4, math.ceil(math.sqrt(inventorySize)))
		local absSize = containerInstance.AbsoluteSize
		local gridCellSize = (math.floor(absSize.X/maxPerRow)) - padding
		return gridCellSize, maxPerRow
	else
		return 40, 4
	end
end

function Inventory:init(props)
	self.frameRef = Roact.createRef()
	self.dragHolderRef = Roact.createRef()
	self.itemFrameRef = Roact.createRef()
	self.maxFillCells = 4
	self.refsTable = {}
	self.swordShieldSlots = {}
	self.itemSlots = {}
	self.craftSlots = {}
	self.viewportSizeListener = currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		self.gridSizeX, self.maxFillCells = self:getGridSizeX()
		self:setState({})
	end)
	self.dragInstance = nil
	self:populateRefsTable()
	self:connectEvents()
	self:setState(function(state)
		return {
			isOpen = true
		}
	end)
	game:GetService("UserInputService").InputBegan:connect(function(inputObject, gameProcessed)
		if inputObject.KeyCode == Enum.KeyCode.G and not gameProcessed then
			self:setState(function(state)
				return {
					isOpen = not state.isOpen
				}
			end)
		end
	end)
end

function Inventory:populateRefsTable()
	for i = 1, 300 do
		self.refsTable[i..""] = Roact.createRef()
	end
end

function Inventory:getGrid(slots, fillDirection, verticalAlignment, size)
	local gridItems = slots
	self.gridSizeX, self.maxFillCells = self:getGridSizeX()
	gridItems["layout"] = Roact.createElement("UIGridLayout", {
		VerticalAlignment = verticalAlignment or "Center",
		HorizontalAlignment = "Center",
		CellSize = size or UDim2.new(0,self.gridSizeX,0,self.gridSizeX),
		CellPadding = UDim2.new(0,12,0,12),
		FillDirection = fillDirection,
		SortOrder = "LayoutOrder",
		FillDirectionMaxCells = self.maxFillCells,
	})
	gridItems["padding"] = Roact.createElement("UIPadding",{
		PaddingLeft = UDim.new(0,6),
		PaddingRight = UDim.new(0,6),
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
	})
	return gridItems
end

function Inventory:updateGridItems()
	local props = self.props
	local userId = tostring(game.Players.LocalPlayer.UserId)
	local inventory = props.inventories[userId]
	local inventorySize = GetInventorySize(game.Players.LocalPlayer)
	local activatedCallback = function(ref,inventoryIndex)
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			local originalSlot = inventoryIndex
			local originalItem = self.props.inventories[userId][originalSlot]

			if tonumber(inventoryIndex) < 200 then
				for i = 200, 203 do
					local slot = i..""
					if not self.props.inventories[userId][slot] then
						local targetSlot = slot
						Messages:sendServer("SwapItems", originalSlot, targetSlot)
						Store:dispatch(SetItemPosition(userId,originalItem, targetSlot))
						return
					end
				end
			else
				for i = 1, inventorySize do
					local slot = i..""
					if not self.props.inventories[userId][slot] then
						local targetSlot = slot
						Messages:sendServer("SwapItems", originalSlot, targetSlot)
						Store:dispatch(SetItemPosition(userId,originalItem, targetSlot))
						return
					end
				end
			end
		end
		local instance = ref.current:Clone()
		instance.BG.BackgroundTransparency =1
		instance.BackgroundTransparency = 1
		instance.ItemLabel:Destroy()
		self.dragSizeX = self.gridSizeX
		self.dragInstance = instance
		if not lastClickedTable[inventoryIndex] then
			lastClickedTable[inventoryIndex] = time()
		else
			if time() - lastClickedTable[inventoryIndex] < .4 then
				Messages:sendServer("UseItem", inventoryIndex)
			end
			lastClickedTable[inventoryIndex] = time()
		end
	end

	self.swordShieldSlots = IconsForSlots(100,101,inventory,activatedCallback,self.refsTable,{
		StyleConstants.THIRST_COLOR,
		StyleConstants.HUNGER_COLOR,
	})
	self.itemSlots = IconsForSlots(1, inventorySize,inventory,activatedCallback,self.refsTable, {})
	self.craftSlots = IconsForSlots(200,203,inventory,activatedCallback,self.refsTable,{StyleConstants.THIRST_COLOR,StyleConstants.THIRST_COLOR,StyleConstants.THIRST_COLOR,StyleConstants.THIRST_COLOR})
end

function Inventory:releaseDrag()
	local userId = tostring(game.Players.LocalPlayer.UserId)
	local position = Vector2.new(game.Players.LocalPlayer:GetMouse().X,game.Players.LocalPlayer:GetMouse().Y)
	local foundSlot
	for i, ref in pairs(self.refsTable) do
		if ref.current then
			if isPointWithinBox(position, ref.current) then
				local originalSlot = self.dragInstance.Name
				local originalItem = self.props.inventories[userId][originalSlot]
				local targetSlot = ref.current.Name
				local slotItem = self.props.inventories[userId][targetSlot]
				Messages:sendServer("SwapItems", originalSlot, targetSlot)
				Store:dispatch(SetItemPosition(userId,originalItem, targetSlot))
				Store:dispatch(SetItemPosition(userId,slotItem, originalSlot))
				foundSlot = true
				break
			end
		end
	end
	if not foundSlot then
		if not isPointWithinBox(position, self.frameRef.current) then
			local target = game.Players.LocalPlayer:GetMouse().Hit.p
			Messages:sendServer("DropItem", self.dragInstance.Name, target)
			Store:dispatch(SetItemPosition(userId,nil, self.dragInstance.Name))
		end
	end
	self.dragInstance:Destroy()
	self.dragInstance = nil
end

function Inventory:connectEvents()
	UserInputService.InputEnded:connect(function(inputObject, gameProcessed)
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
			if inputObject.UserInputState == Enum.UserInputState.End then
				if self.dragInstance then
					self:releaseDrag()
				end
			end
		end
	end)
	game:GetService("RunService").RenderStepped:connect(function()
		if self.dragInstance then
			local mouseX = game.Players.LocalPlayer:GetMouse().X
			local mouseY = game.Players.LocalPlayer:GetMouse().Y
			local sizeX = self.dragSizeX
			self.dragInstance.Parent = self.dragHolderRef.current
			self.dragInstance.Size = UDim2.new(0,sizeX,0,sizeX)
			self.dragInstance.Position = UDim2.new(0,mouseX - self.dragInstance.AbsoluteSize.X/2,0,mouseY- self.dragInstance.AbsoluteSize.Y/2)
		end
		local position = Vector2.new(game.Players.LocalPlayer:GetMouse().X,game.Players.LocalPlayer:GetMouse().Y)
		for i, ref in pairs(self.refsTable) do
			if ref.current then
				if isPointWithinBox(position, ref.current) then
					ref.current.ItemLabel.Visible = true
				else
					ref.current.ItemLabel.Visible = false
				end
			end
		end
		for _, ref in pairs(self.refsTable) do
			local instance = ref.current
			if instance then
				local props = self.props
				local userId = tostring(game.Players.LocalPlayer.UserId)
				local inventory = props.inventories[userId]
				local itemName = inventory[instance.Name]
				if itemName ~= "" and itemName ~= nil then
					for _, frame in pairs(instance:GetChildren()) do
						if frame:IsA("ViewportFrame") and not frame:FindFirstChild(itemName) then
							frame:ClearAllChildren()
							local asset = game.ReplicatedStorage.Assets.Items:FindFirstChild(itemName):Clone()
							asset.Parent = frame
							asset.PrimaryPart = asset.Base
							--asset:SetPrimaryPartCFrame(asset.Base.CFrame * CFrame.Angles(0, math.deg(45),0))
							local camera = Instance.new("Camera", frame)
							local size = asset:GetModelSize()*1.5
							camera.FieldOfView = 45
							camera.CFrame = CFrame.new(asset.Base.Position) * CFrame.new(size.X,size.Y,size.Z)
							camera.CFrame = CFrame.new(camera.CFrame.p, asset:GetModelCFrame().p)
							--camera.CFrame = camera.CFrame * CFrame.new(0, size.Y/2,0)
							asset:SetPrimaryPartCFrame(asset.Base.CFrame * CFrame.Angles(0,0,math.rad(25)))
							frame.CurrentCamera = camera
						end
					end
				else
					for _, frame in pairs(instance:GetChildren()) do
						if frame:IsA("ViewportFrame") then
							frame:ClearAllChildren()
						end
					end
				end
			end
		end
	end)
end

function Inventory:render()
	self:updateGridItems()
	local props = self.props
	local userId = tostring(game.Players.LocalPlayer.UserId)
	local inventory = props.inventories[userId]
	local showCrafting = inventory["200"] or inventory["201"] or inventory["202"] or inventory["203"] or false

	local anchorPoint = Vector2.new(1,.5)
	if not self.state.isOpen then
		anchorPoint = Vector2.new(0,.5)
	end

	local holderFrame = Roact.createElement("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,1,0),
		[Roact.Ref] = self.dragHolderRef
	},{
		frame = Roact.createElement("ImageLabel", {
			Visible = self.props.isOpen,
			Size = UDim2.new(.25,0,.65,0),
			AnchorPoint = anchorPoint,
			Position = UDim2.new(1,0,.5,0),
			BorderSizePixel = 0,
			Image = "rbxassetid://3273520134",
			BackgroundColor3 = StyleConstants.WINDOW_BG,
			[Roact.Ref] = self.frameRef
			-- 1.383 aspect
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0,36),
				PaddingRight = UDim.new(0,36),
				PaddingTop = UDim.new(0,44),
				PaddingBottom = UDim.new(0,44),
			}),
			Constraint = Roact.createElement("UIAspectRatioConstraint", {
				AspectRatio = .722,
			}),
			SwordShieldFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1,0,.2,0),
				BorderSizePixel = 0,
				BackgroundColor3 = StyleConstants.WINDOW_BG,
				BackgroundTransparency = 1,
			}, self:getGrid(self.swordShieldSlots, "Horizontal", "Center", UDim2.new(.2,0,.65,0))),
			ItemsFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1,0,.6,0),
				BorderSizePixel = 0,
				BackgroundColor3 = StyleConstants.WINDOW_BG,
				Position = UDim2.new(0, 0,.2,0),
				BackgroundTransparency = 1,
				[Roact.Ref] = self.itemFrameRef,
			},self:getGrid(self.itemSlots, "Horizontal", "Center")),
			CraftButton = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0,.5),
				BackgroundColor3 = Color3.fromRGB(136,222,113),
				Image = "rbxassetid://3153183087",
				BorderSizePixel = 0,
				Size = UDim2.new(0, self.gridSizeX/2.5,0, self.gridSizeX/2.5),
				Position = UDim2.new(.93,0,.9,0),
				ZIndex = 5,
				Visible = showCrafting,
				[Roact.Event.Activated] = function()
					Messages:sendServer("Craft")
				end
			}),
			CraftingFrame = Roact.createElement("Frame", {
				Size = UDim2.new(1,0,.2,0),
				BorderSizePixel = 0,
				BackgroundColor3 = StyleConstants.WINDOW_BG,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0,.8,0),
			},self:getGrid(self.craftSlots, "Horizontal", "Center", UDim2.new(.2,0,.65,0))),
			tooltipInfo = Roact.createElement("TextLabel", {
				Size = UDim2.new(1,0,.075,0),
				Text = "Double click to use, drag tools into the top two slots to equip them. To craft, drag items into the bottom slots. To build, double click a blueprint in your inventory. Hold left control when clicking to transfer item to crafting.",
				TextScaled = true,
				AnchorPoint = Vector2.new(0,0),
				Position = UDim2.new(0,0,-.075,-52),
				ZIndex = 5,
				BorderSizePixel = 0,
				BackgroundColor3 = StyleConstants.WINDOW_BG,
				TextColor3 = StyleConstants.TEXT,
				Font = StyleConstants.FONT_BOLD,
			}),
			ShowHideButton = Roact.createElement("ImageButton", {
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = StyleConstants.WINDOW_BG,
				BorderSizePixel = 0,
				Image = "rbxassetid://3304517193",
				Size = UDim2.new(0, 50,0,50),
				Position = UDim2.new(0,-85,.5,0),
				ZIndex = 5,
				Rotation = (self.props.isOpen and 180),
				Visible = true,
				[Roact.Event.Activated] = function()
					self:setState(function(state)
						return {
							isOpen = not state.isOpen
						}
					end)
				end
			}),
		}),
	})
	return holderFrame
end

function Inventory:didUpdate()
	self:updateGridItems()
end

function Inventory:willUnmount()
end

local function mapStateToProps(state, props)
	return {
		inventories =state.inventories
	}
end

return Connect(mapStateToProps)(Inventory)
