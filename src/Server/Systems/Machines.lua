local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local MachineData = import "Shared/Data/MachineData"
local CollectionService = game:GetService("CollectionService")
local PlayerData = import "Shared/PlayerData"
local TweenService = game:GetService("TweenService")

local lastColors = {}

local BREAK_TIME = 120

local function breakMachine(machine)
	if not CollectionService:HasTag(machine, "Broken") then
		CollectionService:AddTag(machine, "Broken")
		local particle = game.ReplicatedStorage.Assets.Particles.BrokeSmoke:Clone()
		particle.Parent = machine.Base
		local data = MachineData[machine.Name]
		data.off(machine)
		local fixPercent = Instance.new("IntConstrainedValue", machine)
		fixPercent.Name = "FixPercent"
		fixPercent.MaxValue = math.random(5,10)
		for _, part in pairs(machine:GetChildren()) do
			if part:IsA("BasePart") then
				lastColors[part] = part.BrickColor
				part.BrickColor = BrickColor.new("Black")
			end
		end
	end
end

local function initializeMachines()
	for _, machine in pairs(CollectionService:GetTagged("Machine")) do
		local data = MachineData[machine.Name]
		data.init(machine)
	end
end

local function fix(machine)
	machine.Base.BrokeSmoke:Destroy()
	machine.FixPercent:Destroy()
	CollectionService:RemoveTag(machine, "Broken")
	local data = MachineData[machine.Name]
	data.on(machine)
	local tweenInfo = TweenInfo.new(
		.3,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out,
		0
	)
	for _, part in pairs(machine:GetChildren()) do
		if part:IsA("BasePart") then
			--part.BrickColor = lastColors[part]
			local tween = TweenService:Create(part,tweenInfo, {Color = lastColors[part].Color})
			tween:Play()
		end
	end
end

local Machines = {}

function Machines:start()
	initializeMachines()
	spawn(function()
		local machines = CollectionService:GetTagged("Machine")
		for i, machine in pairs(machines) do
			if machine.Name == "MainPower" then
				table.remove(machines, i)
			end
		end
		breakMachine(machines[math.random(1, #machines)])
		while wait(BREAK_TIME) do
			local machines = CollectionService:GetTagged("Machine")
			for i, machine in pairs(machines) do
				if machine.Name == "MainPower" then
					table.remove(machines, i)
				end
			end
			breakMachine(machines[math.random(1, #machines)])
		end
	end)
	Messages:hook("RepairMachine", function(machine, player)
		if player.Team.Name == "Workers" then
			local amount = math.random(1,2)
			PlayerData:add(player, "cash", amount)
			Messages:sendClient(player, "Notify", "+ $"..amount.."")
		end
		machine.FixPercent.Value = machine.FixPercent.Value + 1
		if machine.FixPercent.Value == machine.FixPercent.MaxValue then
			fix(machine)
		end
	end)
end

return Machines
