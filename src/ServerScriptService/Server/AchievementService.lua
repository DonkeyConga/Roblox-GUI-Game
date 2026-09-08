--!strict
-- Permanent milestone achievements. Check() is idempotent and safe to call after
-- any event that could complete one (roll, rebirth) — it only grants each once.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local AchievementDefs = require(Shared.Achievements)
local Titles = require(Shared.Titles)

local DataService = require(script.Parent.DataService)

local AchievementService = {}

local titlesByRarity: { [string]: { any } } = {}
for _, title in Titles do
	if not title.Exclusive then
		local list = titlesByRarity[title.Rarity]
		if not list then
			list = {}
			titlesByRarity[title.Rarity] = list
		end
		table.insert(list, title)
	end
end

local function isRaritySetComplete(data, rarityName: string): boolean
	local pool = titlesByRarity[rarityName]
	if not pool then
		return false
	end
	for _, title in pool do
		if not data.DiscoveredTitles[title.Id] then
			return false
		end
	end
	return true
end

local function hasDiscoveredRarity(data, rarityName: string): boolean
	for _, title in Titles do
		if title.Rarity == rarityName and data.DiscoveredTitles[title.Id] then
			return true
		end
	end
	return false
end

local function isComplete(data, achievement): boolean
	if achievement.Type == "RollCount" then
		return data.RollCount >= achievement.Target
	elseif achievement.Type == "Rebirths" then
		return data.Rebirths >= achievement.Target
	elseif achievement.Type == "DiscoverRarity" then
		return hasDiscoveredRarity(data, achievement.Rarity)
	elseif achievement.Type == "RaritySet" then
		return isRaritySetComplete(data, achievement.Rarity)
	end
	return false
end

-- Returns newly-completed achievements this call (their coin reward is already granted).
function AchievementService.Check(player: Player)
	local data = DataService.Get(player)
	if not data then
		return {}
	end
	local newlyCompleted = {}
	for _, achievement in AchievementDefs do
		if not data.Achievements[achievement.Id] and isComplete(data, achievement) then
			data.Achievements[achievement.Id] = true
			data.Coins += achievement.Reward
			table.insert(newlyCompleted, achievement)
		end
	end
	if #newlyCompleted > 0 then
		DataService.MarkDirty(player)
	end
	return newlyCompleted
end

function AchievementService.GetSnapshot(player: Player)
	local data = DataService.Get(player)
	if not data then
		return {}
	end
	local list = {}
	for _, achievement in AchievementDefs do
		table.insert(list, {
			Id = achievement.Id,
			Description = achievement.Description,
			Reward = achievement.Reward,
			Completed = data.Achievements[achievement.Id] == true,
		})
	end
	return list
end

return AchievementService
