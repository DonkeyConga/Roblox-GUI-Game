--!strict
-- Daily quests: 3 random quests picked each day, progress tracked as the day
-- goes on, reward paid out only when the player manually claims a finished one.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local QuestDefs = require(Shared.Quests)
local Config = require(Shared.Config)

local DataService = require(script.Parent.DataService)

local QuestService = {}

local questById = {}
for _, quest in QuestDefs do
	questById[quest.Id] = quest
end

local function today(): string
	return os.date("!%Y-%m-%d")
end

local function pickDailyQuests(): { string }
	local pool = {}
	for _, quest in QuestDefs do
		table.insert(pool, quest.Id)
	end
	for i = #pool, 2, -1 do
		local j = math.random(i)
		pool[i], pool[j] = pool[j], pool[i]
	end
	local picked = {}
	for i = 1, math.min(Config.QuestsPerDay, #pool) do
		table.insert(picked, pool[i])
	end
	return picked
end

-- Call on join and after any roll/reward so a new day always resets the board.
function QuestService.RefreshIfNeeded(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end
	local date = today()
	if data.Quests.Date ~= date then
		data.Quests.Date = date
		data.Quests.Active = pickDailyQuests()
		data.Quests.Progress = {}
		data.Quests.Claimed = {}
		DataService.MarkDirty(player)
	end
end

-- questType matches a Quests.lua "Type" field: RollCount, DiscoverCount, CoinsEarned.
-- `amount` is always a delta (this roll, this tick), never a lifetime total —
-- daily quest progress must only count what happened since today's reset.
function QuestService.ReportProgress(player: Player, questType: string, amount: number)
	local data = DataService.Get(player)
	if not data then
		return
	end
	local changed = false
	for _, questId in data.Quests.Active do
		local quest = questById[questId]
		if quest and quest.Type == questType and not data.Quests.Claimed[questId] then
			local current = data.Quests.Progress[questId] or 0
			data.Quests.Progress[questId] = math.min(current + amount, quest.Target)
			changed = true
		end
	end
	if changed then
		DataService.MarkDirty(player)
	end
end

function QuestService.ClaimQuest(player: Player, questId: string)
	local data = DataService.Get(player)
	if not data then
		return { Success = false }
	end
	local quest = questById[questId]
	if not quest or not table.find(data.Quests.Active, questId) then
		return { Success = false, Reason = "InvalidQuest" }
	end
	if data.Quests.Claimed[questId] then
		return { Success = false, Reason = "AlreadyClaimed" }
	end
	local progress = data.Quests.Progress[questId] or 0
	if progress < quest.Target then
		return { Success = false, Reason = "NotComplete" }
	end

	data.Quests.Claimed[questId] = true
	data.Coins += quest.Reward
	DataService.MarkDirty(player)

	return { Success = true, Reward = quest.Reward, NewCoins = data.Coins }
end

function QuestService.GetSnapshot(player: Player)
	local data = DataService.Get(player)
	if not data then
		return {}
	end
	local list = {}
	for _, questId in data.Quests.Active do
		local quest = questById[questId]
		if quest then
			table.insert(list, {
				Id = quest.Id,
				Description = quest.Description,
				Target = quest.Target,
				Reward = quest.Reward,
				Progress = data.Quests.Progress[questId] or 0,
				Claimed = data.Quests.Claimed[questId] == true,
			})
		end
	end
	return list
end

return QuestService
