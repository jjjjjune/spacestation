local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"

local Roact = import "Roact"

local AnimalControlIcons = Roact.PureComponent:extend("AnimalControlIcons")
local CollectionService = game:GetService("CollectionService")
local Icon = import "../Icon"

function AnimalControlIcons:init()
	self:setState({
		aliens = {}
	})
	CollectionService:GetInstanceAddedSignal("Friendly"):connect(function(instance)
		local aliens = self.state.aliens
		table.insert(aliens, instance)
		self:setState({
			aliens = aliens
		})
	end)
	CollectionService:GetInstanceRemovedSignal("Friendly"):connect(function(instance)
		local aliens = self.state.aliens
		for i, alien in pairs(aliens) do
			if alien == instance then
				table.remove(aliens, i)
			end
		end
		self:setState({
			aliens = aliens
		})
	end)
	CollectionService:GetInstanceAddedSignal("Following"):connect(function(instance)
		print("added so set state")
		self:setState({})
	end)
	CollectionService:GetInstanceRemovedSignal("Following"):connect(function(instance)
		print("added so set state")
		self:setState({})
	end)
	local aliens = self.state.aliens
	for _, instance in pairs(CollectionService:GetTagged("Friendly")) do
		table.insert(aliens, instance)
	end
	self:setState({
		aliens = aliens
	})
end

function AnimalControlIcons:willUnmount()
	self.connect:disconnect()
end

function AnimalControlIcons:didMount()

end

function AnimalControlIcons:render()
	local children = {}
	for i, alien in pairs(self.state.aliens) do
		table.insert(children, Roact.createElement(Icon, {
			["adornee"] = alien.Head,
			["following"] = CollectionService:HasTag(alien, "Following")
		}))
	end

	return Roact.createElement("Frame", {
		Size = UDim2.new(1,0,1,0),
		BackgroundTransparency = 1,
	}, children)
end

return AnimalControlIcons
