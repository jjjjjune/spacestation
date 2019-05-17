

return function(humanoid, health, canBeZero)
	if not canBeZero then
		humanoid.Health = math.max(1, humanoid.Health - health)
	else
		humanoid.Health = humanoid.Health - health
	end
end
