local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local hasDestroyed = false

local tweenInfo = TweenInfo.new(
	.3, -- Time
	Enum.EasingStyle.Quad, -- EasingStyle
	Enum.EasingDirection.Out
)

local function destroyModel(model)
	local madeExplosion = false
	for _, p in pairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			if p.Anchored == false then
				return
			else
				p:BreakJoints()
				p.Anchored = false
				if p.Size.Magnitude > 10 then
					p.CanCollide = false
				end
				if not madeExplosion then
					Messages:send("CreateExplosion", p.Position, math.random(10, 30))
				end
			end
		end
	end
end

local function destroySpaceship()
	if hasDestroyed then
		return
	else
		hasDestroyed = true
	end
	workspace.Terrain:Clear()
	workspace.Gravity = 0
	local queue = {}
	for _, model in pairs(workspace:GetChildren()) do
		if not model:FindFirstChild("Humanoid") then
			table.insert(queue, model)
		end
	end
	spawn(function()
		for i, model in pairs(queue) do
			destroyModel(model)
			if i%8 == 0 then
				wait(.5)
			end
		end
	end)
end

local function initializeEngine(engine)
	engine.Health:GetPropertyChangedSignal("Value"):connect(function()
		local goalColor = Color3.fromRGB(109, 166, 96)
		local baseColor = BrickColor.new("Terra Cotta").Color
		local newColor = baseColor:lerp(goalColor, engine.Health.Value/engine.Health.MaxValue)
		local tween = TweenService:Create(engine.Indicator, tweenInfo, {Color = newColor})
		tween:Play()
		if engine.Health.Value == 0 then
			destroySpaceship()
		end
	end)
end

local Engine = {}

function Engine:start()
	local engine = CollectionService:GetTagged("Engine")[1]
	initializeEngine(engine)
	Messages:hook("DamageEngine", function(damage)
		engine.Health.Value = engine.Health.Value - damage
	end)
	Messages:hook("HealEngine", function(damage)
		engine.Health.Value = engine.Health.Value + damage
	end)
	spawn(function()
		for i = 1, 10 do
			wait(1)
			Messages:send("DamageEngine", 100)
		end
	end)
end

return Engine
