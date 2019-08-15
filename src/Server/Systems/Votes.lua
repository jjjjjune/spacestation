local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import 'Shared/Utils/Messages'

local THRESHOLD = .5
local VOTE_TIME = 60
local VOTE_DEBOUNCE = 300

local voteGoing
local lastRan = {}
local lastVotes = {}

local function checkVote(final)
	local needed = (#game.Players:GetPlayers())*THRESHOLD
	if voteGoing.yesVotes > needed then
		for _, member in pairs(game.Teams[voteGoing.team]:GetPlayers()) do
			Messages:send("SwitchTeam", member, "Workers")
			--member:LoadCharacter()
			-- leaving this out for now to see if the chaos is funny
		end
		Messages:sendAllClients("MakeVoteSucceededNotification", voteGoing.running, voteGoing.team, voteGoing.yesVotes, voteGoing.noVotes)
		Messages:send("SwitchTeam", voteGoing.running, voteGoing.team)
		Messages:sendAllClients("Notify", voteGoing.running.Name.." has been elected "..voteGoing.team.."!")
		voteGoing= nil
	else
		if final then
			Messages:sendAllClients("MakeVoteFailedNotification", voteGoing.running,  voteGoing.team,  voteGoing.yesVotes, voteGoing.noVotes)
			voteGoing = nil
		end
	end
end

local function startVote(player, teamName)
	Messages:sendAllClients("MakeVoteNotification", player, teamName, VOTE_TIME)

	voteGoing = {
		running = player,
		yesVotes = 0,
		noVotes = 0,
		voted = {},
		team = teamName
	}

	delay(VOTE_TIME, function()
		checkVote(true)
	end)
end

local function onPlayerVotedYes(player)
	if voteGoing then
		if not voteGoing.voted[player] then
			voteGoing.voted[player] = true
			voteGoing.yesVotes = voteGoing.yesVotes + 1
			checkVote()
		end
	end
end

local function onPlayerVotedNo(player)
	if voteGoing then
		if not voteGoing.voted[player] then
			voteGoing.voted[player] = true
			voteGoing.noVotes = voteGoing.noVotes + 1
			checkVote()
		end
	end
end

local Votes = {}

function Votes:start()
	Messages:hook("StartVote", function(player, teamName)
		if not voteGoing then
			if not lastVotes[teamName] then
				lastVotes[teamName] = time()
			else
				if time() - lastVotes[teamName] < VOTE_DEBOUNCE then
					Messages:sendClient(player, "Notify", "This poisition can only be voted on once every 5 minutes!")
				end
			end
			if not lastRan[player] then
				lastRan[player] =time() - 1000
			end
			if time() - lastRan[player] > VOTE_DEBOUNCE then
				lastRan[player] = time()
				startVote(player, teamName)
				lastVotes[teamName] = time()
			else
				Messages:sendClient(player, "Notify", "You can only run for this once every 5 minutes!")
			end
		else
			Messages:sendClient(player, "Notify", "Someone is already running for a position!")
		end
	end)
	game.Players.PlayerAdded:connect(function(player)
		player.Chatted:connect(function(msg)
			msg = msg:lower()
			local vote = string.sub(msg, 1, 4)
			if vote == "!yes" then
				onPlayerVotedYes(player)
			elseif string.sub(msg,1,3) == "!no" then
				onPlayerVotedNo(player)
			end
		end)
	end)
end

return Votes
