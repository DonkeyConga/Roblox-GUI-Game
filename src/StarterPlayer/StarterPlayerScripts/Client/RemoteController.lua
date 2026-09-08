--!strict
-- Thin client-side wrapper around the shared Remotes so UI code never touches
-- RemoteEvent/RemoteFunction instances directly.
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

RemoteController.OnDataSync = dataSyncEvent.OnClientEvent
RemoteController.OnRollResult = rollResultEvent.OnClientEvent
RemoteController.OnNotify = notifyEvent.OnClientEvent
RemoteController.OnShowDailyReward = showDailyRewardEvent.OnClientEvent

function RemoteController.RollTitle()
	return rollFunction:InvokeServer()
end

function RemoteController.Rebirth()
	return rebirthFunction:InvokeServer()
end

function RemoteController.EquipTitle(titleId: string?)
	return equipFunction:InvokeServer(titleId)
end

function RemoteController.ToggleAutoRoll(enabled: boolean)
	return autoRollFunction:InvokeServer(enabled)
end

function RemoteController.ClaimDailyStreak()
	return claimStreakFunction:InvokeServer()
end

function RemoteController.ClaimQuest(questId: string)
	return claimQuestFunction:InvokeServer(questId)
end

function RemoteController.BuyVIP()
	return buyVIPFunction:InvokeServer()
end

return RemoteController
