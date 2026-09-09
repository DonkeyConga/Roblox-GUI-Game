--!strict
-- Thin client-side wrapper around the shared Remotes so UI code never touches
-- RemoteEvent/RemoteFunction instances directly. Every InvokeServer call is
-- pcall-guarded so a dropped connection or a server-side hiccup comes back as
-- an ordinary { Success = false, Reason = "NetworkError" } instead of an
-- uncaught error that silently kills whatever click handler called it.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.RemoteEvents)

local RemoteController = {}

local dataSyncEvent = Remotes.GetEvent("DataSync")
local rollResultEvent = Remotes.GetEvent("RollResult")
local notifyEvent = Remotes.GetEvent("Notify")
local showDailyRewardEvent = Remotes.GetEvent("ShowDailyReward")

local rollFunction = Remotes.GetFunction("RollTitle")
local rebirthFunction = Remotes.GetFunction("Rebirth")
local equipFunction = Remotes.GetFunction("EquipTitle")
local autoRollFunction = Remotes.GetFunction("ToggleAutoRoll")
local claimStreakFunction = Remotes.GetFunction("ClaimDailyStreak")
local claimQuestFunction = Remotes.GetFunction("ClaimQuest")
local buyVIPFunction = Remotes.GetFunction("BuyVIP")
local requestSyncFunction = Remotes.GetFunction("RequestSync")

RemoteController.OnDataSync = dataSyncEvent.OnClientEvent
RemoteController.OnRollResult = rollResultEvent.OnClientEvent
RemoteController.OnNotify = notifyEvent.OnClientEvent
RemoteController.OnShowDailyReward = showDailyRewardEvent.OnClientEvent

local function safeInvoke(remoteFunction: RemoteFunction, ...): any
	local success, result = pcall(function(...)
		return remoteFunction:InvokeServer(...)
	end, ...)
	if not success then
		warn(`[RemoteController] {remoteFunction.Name} failed: {result}`)
		return { Success = false, Reason = "NetworkError" }
	end
	return result
end

function RemoteController.RollTitle()
	return safeInvoke(rollFunction)
end

function RemoteController.Rebirth()
	return safeInvoke(rebirthFunction)
end

function RemoteController.EquipTitle(titleId: string?)
	return safeInvoke(equipFunction, titleId)
end

function RemoteController.ToggleAutoRoll(enabled: boolean)
	return safeInvoke(autoRollFunction, enabled)
end

function RemoteController.ClaimDailyStreak()
	return safeInvoke(claimStreakFunction)
end

function RemoteController.ClaimQuest(questId: string)
	return safeInvoke(claimQuestFunction, questId)
end

function RemoteController.BuyVIP()
	return safeInvoke(buyVIPFunction)
end

-- Pulls the player's current data directly, instead of only waiting on the
-- server's join-time push — see the comment atop Init.server.lua for why.
-- Returns nil if the server hasn't finished loading this player's save yet.
function RemoteController.RequestSync()
	local success, result = pcall(function()
		return requestSyncFunction:InvokeServer()
	end)
	if not success then
		warn(`[RemoteController] RequestSync failed: {result}`)
		return nil
	end
	return result
end

return RemoteController
