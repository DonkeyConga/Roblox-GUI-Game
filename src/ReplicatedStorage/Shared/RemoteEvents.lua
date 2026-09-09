--!strict
-- Thin wrapper around a ReplicatedStorage.Remotes folder shared by server and client.
-- Server calls Setup() once at startup so every remote exists before any client
-- can possibly ask for one; both sides then use GetEvent/GetFunction to fetch them.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvents = {}

local EVENT_NAMES = { "DataSync", "RollResult", "Notify", "ShowDailyReward" }
local FUNCTION_NAMES = {
	"RollTitle",
	"Rebirth",
	"EquipTitle",
	"ToggleAutoRoll",
	"ClaimDailyStreak",
	"ClaimQuest",
	"BuyVIP",
	"RequestSync",
}

local function getOrCreateFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
	return folder :: Folder
end

function RemoteEvents.Setup()
	local folder = getOrCreateFolder()
	for _, name in EVENT_NAMES do
		if not folder:FindFirstChild(name) then
			local event = Instance.new("RemoteEvent")
			event.Name = name
			event.Parent = folder
		end
	end
	for _, name in FUNCTION_NAMES do
		if not folder:FindFirstChild(name) then
			local func = Instance.new("RemoteFunction")
			func.Name = name
			func.Parent = folder
		end
	end
end

function RemoteEvents.GetEvent(name: string): RemoteEvent
	local folder = getOrCreateFolder()
	local event = folder:WaitForChild(name, 10)
	assert(event, `Missing RemoteEvent {name}`)
	return event :: RemoteEvent
end

function RemoteEvents.GetFunction(name: string): RemoteFunction
	local folder = getOrCreateFolder()
	local func = folder:WaitForChild(name, 10)
	assert(func, `Missing RemoteFunction {name}`)
	return func :: RemoteFunction
end

return RemoteEvents
