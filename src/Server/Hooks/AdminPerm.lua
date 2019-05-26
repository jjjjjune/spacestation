return function (registry)
	registry:RegisterHook("BeforeRun", function(context)
		print(context.Group)
		if (context.Executor.UserId ~= game.CreatorId) and (not game:GetService("RunService"):IsStudio()) then
			return "You don't have permission to run this command"
		end
	end)
end
