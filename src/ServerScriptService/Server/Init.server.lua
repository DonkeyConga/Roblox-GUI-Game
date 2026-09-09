--!strict
-- Boots every server service and wires the Remotes to them. This is the only
-- script that should ever touch RemoteFunction.OnServerInvoke / FireClient
-- directly — everything else lives behind a service module's plain functions.
--
-- IMPORTANT: the join-time DataSync push below is a fire-and-forget
-- RemoteEvent — if the client's listener isn't connected yet when it fires,
-- that payload is lost for good (Roblox does not queue/replay RemoteEvents).
-- RequestSync exists so the client can pull its own data once it's actually
-- ready to receive it, instead of only hoping this push wins the race.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(ReplicatedStorage.Shared.RemoteEvents)
Remotes.Setup()

local DataService = require(script.Parent.DataService)
local RollService = require(script.Parent.RollService)
local RebirthService = require(script.Parent.RebirthService)
local StreakService = require(script.Parent.StreakService)
local QuestService = require(script.Parent.QuestService)
local AchievementService = require(script.Parent.AchievementService)
local AutoRollService = require(script.Parent.AutoRollService)
local EconomyService = require(script.Parent.EconomyService)
local GamepassService = require(script.Parent.GamepassService)
local LeaderstatsService = require(script.Parent.LeaderstatsService)

DataService.Init()
EconomyService.Init()

local dataSyncEvent = Remotes.GetEvent("DataSync")
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

local function buildSyncPayload(player: Player)
	local data = DataService.Get(player)
	if not data then
		return nil
	end
	return {
		Treats = data.Treats,
		Rebirths = data.Rebirths,
		EquippedTitle = data.EquippedTitle,
		DiscoveredTitles = data.DiscoveredTitles,
		RollCount = data.RollCount,
		RollsSincePity = data.RollsSincePity,
		AutoRollEnabled = data.AutoRollEnabled,
		LoginStreak = data.LoginStreak,
		OwnsVIP = data.OwnsVIP,
		SetBonuses = data.SetBonuses,
		Achievements = AchievementService.GetSnapshot(player),
		Quests = QuestService.GetSnapshot(player),
		RollCost = RollService.GetRollCost(data),
		RebirthRequirement = RebirthService.GetRequirement(data),
		CanAutoRoll = AutoRollService.CanUseAutoRoll(data),
	}
end

local function pushDataSync(player: Player)
	local payload = buildSyncPayload(player)
	if payload then
		dataSyncEvent:FireClient(player, payload)
	end
end

GamepassService.Init(function(player: Player)
	AchievementService.Check(player)
	pushDataSync(player)
end)

Players.PlayerAdded:Connect(function(player: Player)
	local data = DataService.Load(player)

	GamepassService.CheckOwnership(player)
	local afkGained = EconomyService.GrantAFKGains(player)

	QuestService.RefreshIfNeeded(player)
	AchievementService.Check(player)

	LeaderstatsService.Create(player)

	if data.EquippedTitle then
		RollService.EquipTitle(player, data.EquippedTitle)
	end

	pushDataSync(player)

	if afkGained > 0 then
		notifyEvent:FireClient(player, {
			Type = "Success",
			Message = `Welcome back! You earned {afkGained} treats while away.`,
		})
	end

	local streakInfo = StreakService.Peek(player)
	if streakInfo then
		showDailyRewardEvent:FireClient(player, streakInfo)
	end
end)

Players.PlayerRemoving:Connect(function(player: Player)
	AutoRollService.Stop(player)
	local data = DataService.Get(player)
	if data then
		data.LastSeen = os.time()
	end
	DataService.Release(player)
end)

-- The client calls this once its own DataSync listener is wired up, so it
-- always ends up with correct data regardless of how the join-time push race
-- resolved. Returns nil if this player's save hasn't finished loading yet —
-- in that case the client just waits for the DataSync push that follows Load.
requestSyncFunction.OnServerInvoke = function(player: Player)
	return buildSyncPayload(player)
end

rollFunction.OnServerInvoke = function(player: Player)
	local result = RollService.PerformRoll(player)
	if result.Success then
		QuestService.RefreshIfNeeded(player)
		pushDataSync(player)
	end
	return result
end

rebirthFunction.OnServerInvoke = function(player: Player)
	local result = RebirthService.PerformRebirth(player)
	if result.Success then
		pushDataSync(player)
	end
	return result
end

equipFunction.OnServerInvoke = function(player: Player, titleId: string?)
	local success = RollService.EquipTitle(player, titleId)
	if success then
		pushDataSync(player)
	end
	return { Success = success }
end

autoRollFunction.OnServerInvoke = function(player: Player, enabled: boolean)
	local success = AutoRollService.SetEnabled(player, enabled)
	pushDataSync(player)
	return { Success = success }
end

claimStreakFunction.OnServerInvoke = function(player: Player)
	local result = StreakService.Claim(player)
	if result.Success then
		AchievementService.Check(player)
		pushDataSync(player)
	end
	return result
end

claimQuestFunction.OnServerInvoke = function(player: Player, questId: string)
	local result = QuestService.ClaimQuest(player, questId)
	if result.Success then
		pushDataSync(player)
	end
	return result
end

buyVIPFunction.OnServerInvoke = function(player: Player)
	return { Success = GamepassService.PromptVIP(player) }
end
