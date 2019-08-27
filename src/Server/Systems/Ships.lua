local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")

local shipResource = import "Assets/Ships/Default"
local startPoint = CollectionService:GetTagged("ShipStart")[1]
local endPoint = CollectionService:GetTagged("DockDrop")[1]

local FRAMES = 400

local function makeShip(item)
	local itemInstance = game.ReplicatedStorage.Assets.Objects[item]:Clone()
	local shipInstance = shipResource:Clone()
	shipInstance.Parent = workspace
	shipInstance.PrimaryPart = shipInstance.Base
	shipInstance:SetPrimaryPartCFrame(startPoint.CFrame)
	shipInstance.Base.BodyPosition.Position = startPoint.Position
	for _, v in pairs(shipInstance:GetChildren()) do
		if v:IsA("BasePart") then
			v.Touched:connect(function(hit)
				if CollectionService:HasTag(hit.Parent, "Ship") and not hit:IsDescendantOf(v.Parent) then
					if not CollectionService:HasTag(shipInstance, "Exploded") then
						CollectionService:AddTag(shipInstance, "Exploded")
						shipInstance.Base.BodyGyro:Destroy()
						shipInstance.Base.RotVelocity = Vector3.new(math.random(), math.random(), math.random())*100
						for _, v in pairs(shipInstance:GetChildren()) do
							if math.random(1,3) == 1 then
								if v:IsA("BasePart") then
									v:BreakJoints()
								end
							end
						end
						Messages:send("CreateExplosion", hit.Position, 30)
						shipInstance.Base.BodyPosition.Name = "BreakTheLoopTho"
						shipInstance.Base.ShipEngine:Destroy()
						game:GetService("Debris"):AddItem(shipInstance, 30)
					end
				end
			end)
		end
	end
	itemInstance.Parent = workspace
	itemInstance.PrimaryPart = itemInstance.Base
	itemInstance:SetPrimaryPartCFrame(shipInstance.Base.CFrame * CFrame.new(0,-10,0))
	local shipSound = game.ReplicatedStorage.Assets.Sounds.ShipEngine:Clone()
	shipSound.Parent = shipInstance.Base
	shipSound:Play()
	local attach1 = Instance.new("Attachment", shipInstance.Base)
	local attach2 = Instance.new("Attachment", itemInstance.Base)
	local rope = Instance.new("RopeConstraint", shipInstance.Base)
	rope.Length = 10
	rope.Attachment0 = attach1
	rope.Attachment1 = attach2
	rope.Visible = true
	rope.Restitution = 0
	local dist = (startPoint.Position - endPoint.Position).magnitude
	local frames = FRAMES
	local amountPer = dist/frames
	spawn(function()
		local cf = shipInstance.PrimaryPart.CFrame
		for i = 1, frames do
			shipInstance.Base.BodyPosition.Position = cf.p
			cf = cf * CFrame.new(0,0,-amountPer)
			wait()
		end
		wait(2)
		shipInstance.Base.BodyPosition.Position = shipInstance.Base.Position - Vector3.new(0,20,0)
		cf = cf * CFrame.new(0,-24,0)
		wait(1)
		Messages:send("PlaySound","DoorLight", shipInstance.Base.Position)
		rope:Destroy()
		wait(2)
		shipInstance.Base.BodyPosition.P = shipInstance.Base.BodyPosition.P/6
		shipInstance.Base.BodyPosition.Position = shipInstance.Base.Position + Vector3.new(0,5000,0)
		wait(22)
		shipInstance:Destroy()
	end)
end

local Ships = {}

function Ships:start()
	Messages:hook("MakeShip", function(item)
		makeShip(item)
	end)
end

return Ships
