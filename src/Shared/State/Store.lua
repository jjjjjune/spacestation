--[[
	Singleton store for use with our root state.

	Usage:

		local store = import "Shared/State/Store"
		store:dispatch({ type = "FOO" })

	Keeping this as a singleton means we have easy access to the store at any
	time, which is especially useful as an escape hatch.

	In the interest of keeping code testable, it's recommended that the store
	(or better yet, just the state) is passed in as an argument to most
	functions. Accessing it from a module's global scope makes it much harder to
	test, as the state is no longer isolated.

	This is the difference between:

		local store = import "Shared/State/Store"

		local function foo()
			local state = store:getState()
		end

	And:

		local function foo(store)
			local state = store:getState()
		end

	In the latter case, we can pass in a mock store to the `foo` function, which
	makes testing specific cases easy. Whereas in the former we have no way to
	control what the state looks like beforehand.
]]

local import = require(game.ReplicatedStorage.Shared.Import)

local Rodux = import("Rodux")
local DevSettings = import "Shared/Data/DevSettings"
local RootReducer = import "../RootReducer"
local StateLoggerMiddleware = import "../Middleware/StateLoggerMiddleware"

local middlewares = {
	Rodux.thunkMiddleware,
}

if DevSettings.IS_STATE_LOGGED then
	table.insert(middlewares, StateLoggerMiddleware)
end

local store = Rodux.Store.new(RootReducer, nil, middlewares)

return store
