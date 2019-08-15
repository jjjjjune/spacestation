
local import = require(game.ReplicatedStorage.Shared.Import)
local Messages = import "Shared/Utils/Messages"
local CollectionService = game:GetService("CollectionService")
local originalCollide = {}
local oldJoints = {}

local function ragdoll(character)
	CollectionService:AddTag(character, "Ragdolled")
	local d = character:GetDescendants()
	if not originalCollide[character] then
		originalCollide[character] = {}
	end
	if not oldJoints[character] then
		oldJoints[character] = {}
	end
	for i=1,#d do
		local desc = d[i]
		if desc:IsA("Motor6D") and desc.Name ~= "Neck" then
			local socket = Instance.new("HingeConstraint")
			local part0 = desc.Part0
			local joint_name = desc.Name
			local attachment0 = desc.Parent:FindFirstChild(joint_name.."Attachment") or desc.Parent:FindFirstChild(joint_name.."RigAttachment")
			local attachment1 = part0:FindFirstChild(joint_name.."Attachment") or part0:FindFirstChild(joint_name.."RigAttachment")
			if attachment0 and attachment1 then
				socket.Attachment0, socket.Attachment1 = attachment0, attachment1
				socket.Parent = desc.Parent
				socket.Radius = 180

				local n = desc.Parent.Name
				if n == "LeftHand"  or n == "RightHand" or n == "LeftFoot" or n == "RightFoot" then
					local clone = desc.Parent:Clone()
					clone.Name = "fake"
					clone.CanCollide = true
					clone.Transparency = 1
					for _, v in pairs(clone:GetChildren()) do
						v:Destroy()
					end
					local w = Instance.new("WeldConstraint", clone)
					w.Part0 = clone
					w.Part1 = desc.Part1
					clone.Parent = desc.Parent.Parent
					originalCollide[character][desc.Parent] = clone
				end

				oldJoints[character][desc.Parent] = desc
				desc.Parent = nil
			end
		end
	end
	character.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end

local function unragdoll(character)
	if character.Humanoid.Health <= 0 then
		return -- no unragdoll for the dead
	end
	CollectionService:RemoveTag(character, "Ragdolled")
	local d = character:GetDescendants()
	for i=1,#d do
		local desc = d[i]
		if desc:IsA("HingeConstraint") then
			desc:Destroy()
		end
	end
	for originalParent, joint in pairs(oldJoints[character]) do
		joint.Parent = originalParent
		joint.Part1 = originalParent
		oldJoints[character][originalParent] = nil
	end
	for p, part in pairs(originalCollide[character]) do
		part:Destroy()
	end
	character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end


local Ragdoll = {}

function Ragdoll:start()
	Messages:hook("RagdollCharacter", function(character)
		local ragdolled = CollectionService:HasTag(character, "Ragdolled")
		if not ragdolled or game:GetService("RunService"):IsClient() then
			ragdoll(character)
		end
	end)
	Messages:hook("UnragdollCharacter", function(character)
		local ragdolled = CollectionService:HasTag(character, "Ragdolled")
		if ragdolled or game:GetService("RunService"):IsClient() then
			unragdoll(character)
		end
	end)
end

return Ragdoll
