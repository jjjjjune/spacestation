-- Credit to Stravant

--[[
	class Signal

	Description:
		Lua-side duplication of the API of Events on Roblox objects. Needed for nicer
		syntax, and to ensure that for local events objects are passed by reference
		rather than by value where possible, as the BindableEvent objects always pass
		their signal arguments by value, meaning tables will be deep copied when that
		is almost never the desired behavior.

	API:
		void fire(...)
			Fire the event with the given arguments.

		Connection connect(Function handler)
			Connect a new handler to the event, returning a connection object that
			can be disconnected.

		... wait()
			Wait for fire to be called, and return the arguments it was given.
--]]

local Connection = {}
Connection.__index = Connection

function Connection.new(signaler, f)
	return setmetatable({
		signaler = signaler,
		f = f
	}, Connection)
end

function Connection:disconnect(args)
	local connected = self.signaler.connected
	for i = #connected, 1, -1 do
		if connected[i] == self then
			table.remove(connected, i)
		end
	end
end

Connection.Disconnect = Connection.disconnect


local Signal = {}

function Signal.new()
	local sig = {}

	local mSignaler = Instance.new('BindableEvent')
	local mArgData = nil
	local mArgDataCount = nil

	function sig:fire(...)
		mArgData = {...}
		mArgDataCount = select('#', ...)
		mSignaler:Fire()
	end

	function sig:connect(f)
		if not f then error("connect(nil)", 2) end
		return mSignaler.Event:connect(function()
			f(unpack(mArgData, 1, mArgDataCount))
		end)
	end

	function sig:wait()
		mSignaler.Event:wait()
		assert(mArgData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
		return unpack(mArgData, 1, mArgDataCount)
	end

	sig.Fire = sig.fire
	sig.Connect = sig.connect
	sig.Wait = sig.wait

	setmetatable(sig, {
		__tostring = function(self)
			return "Custom Signal"
		end
	})
	return sig
end

return Signal
