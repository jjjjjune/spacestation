--[[
	Global configuration for the game.

	The constants in this file are developer preferences. To change one for
	yourself, create a new file named DevSettingsLocal in this folder. This file
	is ignored by Git, so will not be picked up by other developers.

	Constants in this file are the default values and should not be modified.
	DevSettingsLocal is how you override the defaults for yourself.

	In DevSettingsLocal, simply return a table with key/value pairs for matching
	constants in CONFIG. If you were to return `{ DEBUG_MODE = true }`, that
	would enable debug mode for you only.
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local Immutable = import "Immutable"

local CONFIG = {
	-- Turns on a generic debug mode. This typically makes output more verbose,
	-- printing things you otherwise wouldn't see.
	DEBUG_MODE = false,

	-- Whether or not the state is logged every time something changes.
	--
	-- Because this tends to clutter up the output, it's best left as a setting
	-- that the current developer can configure on their own machine.
	IS_STATE_LOGGED = false,
}

-- This is the file where you can make changes to the global config.
local localConfig = script.Parent:FindFirstChild("DevSettingsLocal")

if localConfig then
	return Immutable.join(CONFIG, require(localConfig))
else
	return CONFIG
end
