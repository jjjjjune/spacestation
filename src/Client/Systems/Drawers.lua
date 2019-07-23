local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")

local MAX_DISTANCE = 10

local player = game.Players.LocalPlayer
local lastDrawer

local function getClosestDrawer(position)
	local closestDist = MAX_DISTANCE
	local closestDrawer = nil
	for _, drawer in pairs(CollectionService:GetTagged("Drawer")) do
		local dist = (drawer.Base.Position - position).magnitude
		if dist < closestDist then
			closestDrawer = drawer
			closestDist = dist
		end
	end
	return closestDrawer
end

local function close(drawer)
	if drawer.Open.Value == true then
		drawer.PrimaryPart = drawer.Base
		drawer:SetPrimaryPartCFrame(drawer.PrimaryPart.CFrame * CFrame.new(0,0,drawer.Base.Size.Z*.75))
		drawer.Open.Value = false
		Messages:send("PlaySoundClient", "DrawerClose")
	end
end


local function open(drawer)
	if not drawer:FindFirstChild("Open") then
		local openValue = Instance.new("BoolValue",drawer)
		openValue.Name = "Open"
		openValue.Value = false
	end
	if drawer.Open.Value == false then
		if lastDrawer and lastDrawer ~= drawer then
			close(lastDrawer)
		end
		lastDrawer = drawer
		drawer.PrimaryPart = drawer.Base
		drawer:SetPrimaryPartCFrame(drawer.PrimaryPart.CFrame * CFrame.new(0,0,-drawer.Base.Size.Z*.75))
		drawer.Open.Value = true
		Messages:send("PlaySoundClient", "DrawerOpen")
	end
end

local function drawerLoop()
	spawn(function()
		while wait(.25) do
			local found = false
			local character = player.Character
			if character then
				local root = character.PrimaryPart
				if root then
					local drawer = getClosestDrawer(root.Position)
					if drawer then
						print("yeah drawer")
						open(drawer)
						Messages:send("SetDrawer", drawer)
						found = true
					else
						if lastDrawer and lastDrawer ~= drawer and math.ceil((lastDrawer.Base.Position - player.Character.PrimaryPart.Position).magnitude) > MAX_DISTANCE + 1 then
							close(lastDrawer)
							lastDrawer = nil
							print("closing")
						end
					end
				end
			end
			if not found then
				Messages:send("SetDrawer", nil)
			end
		end
	end)
end

local Drawers = {}

function Drawers:start()
	spawn(drawerLoop)
end

return Drawers
