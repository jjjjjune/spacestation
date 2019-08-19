local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local AddCash = import "Shared/Utils/AddCash"

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
				if p.Name ~= "Base" and p.Name ~= "Platform" and p.Name ~= "PlatformDisplay" and p.Name ~= "Label" then
					p:Destroy()
				end
				--return
			else
				p:BreakJoints()
				p.Anchored = false
				p.CanCollide = false
				if p.Size.Magnitude > 10 then
					p.Velocity = Vector3.new(1,1,1) * ((math.random(0,1000)/1000)-.5)
					p.CanCollide = true
				end
				if math.random(1, 20) == 1 then
					--madeExplosion = true
					Messages:send("CreateExplosion", p.Position, math.random(10, 30))
				end
				if math.random(1, 6) == 1 and p.Name ~= "Base" and p.Name ~= "Platform" and p.Name ~= "PlatformDisplay" and p.Name ~= "Label" then
					p:Destroy()
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
	for _, p in pairs(game.Players:GetPlayers()) do
		if p.Character then
			if CollectionService:HasTag(p.Character, "Alien") then
				AddCash(p, 250)
			end
		end
	end
	workspace.MainPower:MoveTo(Vector3.new(0,10000,0))
	workspace.MainPower.Parent = game.ServerStorage
	game.Lighting.Brightness = 0
	game.Lighting.OutdoorAmbient = Color3.fromRGB(7,58,72)
	game.Lighting.Ambient = Color3.new(0,0,0)
	Messages:sendAllClients("NoGrav")
	workspace.Terrain:Clear()
	workspace.Gravity = 0
	local queue = {}
	for _, model in pairs(workspace:GetChildren()) do
		if not game.Players:GetPlayerFromCharacter(model) and model:IsA("Model") then
			table.insert(queue, model)
		end
	end
	spawn(function()
		for i, model in pairs(queue) do
			destroyModel(model)
			wait(.1)
		end
		wait(45)
		for _, p in pairs(game.Players:GetPlayers()) do
			p:Kick("The space station has died.")
		end
	end)
end

local function initializeEngine(engine)
	engine.Health:GetPropertyChangedSignal("Value"):connect(function()
		local goalColor = Color3.fromRGB(109, 166, 96)
		local baseColor = BrickColor.new("Bright red").Color
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
end

return Engine
