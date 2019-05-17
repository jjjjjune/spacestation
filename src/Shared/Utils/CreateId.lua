local import = require(game.ReplicatedStorage.Shared.Import)

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local t = import "t"

local idCounters = {}
local function createMockId(name)
    assert(t.string(name))

    local counter = idCounters[name]
    if counter then
        counter = counter + 1
    else
        counter = 1
    end
    idCounters[name] = counter

    return ("%s_%i"):format((name):upper(), counter)
end

--[[
    Generates a unique ID.

    While in studio, this ID is based off the given name to make debugging
    easier. In live servers, a GUID is used instead to ensure everything is
    unique across play sessions.

    string name The name to use while offline. This is essentially a namespace.
        The generated ID for a name of "foo," for example, would look like "FOO_1"
]]
local function createId(name)
    assert(t.string(name))

    if RunService:IsStudio() then
        return createMockId(name)
    else
        return HttpService:GenerateGUID()
    end
end

return createId