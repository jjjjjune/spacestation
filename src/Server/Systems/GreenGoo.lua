local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(
	.3, -- Time
	Enum.EasingStyle.Quad, -- EasingStyle
	Enum.EasingDirection.Out
)

local function refillGoo(well)
	well.Amount.Value = well.Amount.MaxValue
end

local function updateGoo(well)
	Messages:send("PlaySound", "Drinking", well.Base.Position)
	local percent = well.Amount.Value/well.Amount.MaxValue
	local newSize = Vector3.new(well.Goo.Size.X, well.Base.Size.Y + (24*percent), well.Goo.Size.Z)
	local tween = TweenService:Create(well.Goo, tweenInfo, {Size = newSize})
	tween:Play()
end

local function initializeGoo(well)
	local amount = Instance.new("IntConstrainedValue")
	amount.MaxValue = 100
	amount.Value = 50
	amount.Name = "Amount"
	amount.Parent = well
	amount:GetPropertyChangedSignal("Value"):connect(function()
		updateGoo(well)
	end)
end

local GreenGoo = {}

function GreenGoo:start()
	for _, well in pairs(CollectionService:GetTagged("GooHolder")) do
		initializeGoo(well)
		updateGoo(well)
	end
	Messages:hook("HealCharacter", function(player, character)
		if character.Humanoid.Health < character.Humanoid.MaxHealth then
			local medigun = player.Character:FindFirstChild("Medigun")
			if medigun.Amount.Value > 0 then
				character.Humanoid.Health = character.Humanoid.Health + 1
				medigun.Amount.Value = medigun.Amount.Value - 1
			end
			local scale = medigun.Amount.Value/medigun.Amount.MaxValue
			local maxHeight = 1.5
			medigun.Goo.Mesh.Scale = Vector3.new(1,1 + (maxHeight*scale),1)
			medigun.Goo.Mesh.Offset = Vector3.new(0,0 + ((maxHeight/2)*scale), 0)
		end
	end)
	Messages:hook("FillMedigun", function(player, gooHolder)
		if gooHolder.Amount.Value > 0 then
			gooHolder.Amount.Value = gooHolder.Amount.Value - 10
			player.Character.Medigun.Amount.Value = 300
			local medigun = player.Character.Medigun
			local scale = medigun.Amount.Value/medigun.Amount.MaxValue
			local maxHeight = 1.5
			medigun.Goo.Mesh.Scale = Vector3.new(1,1 + (maxHeight*scale),1)
			medigun.Goo.Mesh.Offset = Vector3.new(0,0 + ((maxHeight/2)*scale), 0)
		else
			Messages:sendClient(player, "Notify", "This container needs more goo!")
		end
	end)
	Messages:hook("OnObjectReleased", function(player, object)
		for _, well in pairs(CollectionService:GetTagged("GooHolder")) do
			if CollectionService:HasTag(object, "Goo") then
				if (well.Base.Position - object.Base.Position).magnitude < 10 then
					refillGoo(well)
					object:Destroy()
				end
			end
		end
	end)
end

return GreenGoo
