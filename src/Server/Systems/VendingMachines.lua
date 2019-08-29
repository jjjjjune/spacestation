local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'
local CollectionService = game:GetService("CollectionService")
local PlayerData = import 'Shared/PlayerData'

local lastSound = time()

local machineContents = {}

local function attemptOrderFrom(player, vendingMachine, price)
	if #machineContents[vendingMachine] > 0 then
		Messages:send("PlaySound", "Chime", vendingMachine.Base.Position)
		PlayerData:add(player, "cash", -1)
		local item = machineContents[vendingMachine][1]
		item.Parent = workspace
		item:SetPrimaryPartCFrame(vendingMachine.Out.CFrame)
	end
end

local function initializeMachine(vendingMachine)
	machineContents[vendingMachine] = {}
	local detector = Instance.new("ClickDetector", vendingMachine.BuyButton)
	Messages:send("RegisterDetector", detector, function(player)
		local cash = PlayerData:get(player, "cash")
		local price = math.max(1, #game.Teams.Cooks:GetPlayers())
		if cash >= price then
			attemptOrderFrom(player, vendingMachine, price)
		else
			if time() - lastSound > 1 then
				Messages:send("PlaySound", "Error", vendingMachine.Base.Position)
				lastSound = time()
			end
		end
	end)
end

local VendingMachines = {}

function VendingMachines:start()
	for _, vendingMachine in pairs(CollectionService:GetTagged("VendingMachine")) do
		initializeMachine(vendingMachine)
	end
end

return VendingMachines
