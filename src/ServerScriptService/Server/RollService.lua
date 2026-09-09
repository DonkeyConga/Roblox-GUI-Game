--!strict
-- The core RNG loop: spend treats, roll a weighted rarity, pick a title from
-- that rarity's pool, track pity and discovery, and report side effects to
-- quests/achievements/index bonuses.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage.Shared

local Config = require(Shared.Config)
local Rarities = require(Shared.Rarities)
local Titles = require(Shared.Titles)

local DataService = require(script.Parent.DataService)
local QuestService = require(script.Parent.QuestService)
local AchievementService = require(script.Parent.AchievementService)

local RollService = {}

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

local rarityByName = {}
for _, rarity in Rarities do
	rarityByName[rarity.Name] = rarity
end

local PITY_MIN_INDEX = Config.PityMinRarityIndex

function RollService.GetRollCost(data): number
	return math.floor(Config.BaseRollCost * (Config.RollCostGrowthPerRebirth ^ data.Rebirths))
end

function RollService.GetLuckMultiplier(data): number
	local luck = 1 + (data.Rebirths * Config.RebirthLuckBonusPerRebirth)
	if data.OwnsVIP then
		luck *= Config.VIPLuckMultiplier
	end
	for _ in data.SetBonuses do
		luck += Config.SetBonusLuckBonus
	end
	return luck
end

function RollService.GetTreatMultiplier(data): number
	local mult = 1 + (data.Rebirths * Config.RebirthTreatBonusPerRebirth)
	if data.OwnsVIP then
		mult *= Config.VIPTreatMultiplier
	end
	if data.EquippedTitle then
		for _, title in Titles do
			if title.Id == data.EquippedTitle then
				local rarity = rarityByName[title.Rarity]
				if rarity then
					mult *= (1 + rarity.Boost)
				end
				break
			end
		end
	end
	return mult
end

-- Weighted pick across Rarities (or only those >= minIndex, for pity rolls).
-- Luck multiplies every non-Common weight, then everything is renormalized.
local function weightedRandomRarity(luckMultiplier: number, minIndex: number?)
	local total = 0
	local weights = {}
	for _, rarity in Rarities do
		if minIndex and rarity.Index < minIndex then
			continue
		end
		local weight = rarity.Weight
		if rarity.Index > 1 then
			weight *= luckMultiplier
		end
		weights[rarity] = weight
		total += weight
	end

	local roll = math.random() * total
	local cumulative = 0
	for rarity, weight in weights do
		cumulative += weight
		if roll <= cumulative then
			return rarity
		end
	end
	return Rarities[1]
end

function RollService.CheckSetBonus(player: Player, rarityName: string): boolean
	local data = DataService.Get(player)
	if not data or data.SetBonuses[rarityName] then
		return false
	end
	local pool = titlesByRarity[rarityName]
	if not pool then
		return false
	end
	for _, title in pool do
		if not data.DiscoveredTitles[title.Id] then
			return false
		end
	end
	data.SetBonuses[rarityName] = true
	DataService.MarkDirty(player)
	return true
end

function RollService.PerformRoll(player: Player)
	local data = DataService.Get(player)
	if not data then
		return { Success = false, Reason = "NoData" }
	end

	local cost = RollService.GetRollCost(data)
	if data.Treats < cost then
		return { Success = false, Reason = "NotEnoughTreats", Cost = cost }
	end

	data.Treats -= cost
	data.RollsSincePity += 1

	local luck = RollService.GetLuckMultiplier(data)
	local pityTriggered = false
	local rarity

	if data.RollsSincePity >= Config.PityRollThreshold then
		rarity = weightedRandomRarity(luck, PITY_MIN_INDEX)
		pityTriggered = true
	else
		rarity = weightedRandomRarity(luck)
	end

	if rarity.Index >= PITY_MIN_INDEX then
		data.RollsSincePity = 0
	end

	local pool = titlesByRarity[rarity.Name]
	local title = pool[math.random(1, #pool)]

	local isNew = not data.DiscoveredTitles[title.Id]
	data.DiscoveredTitles[title.Id] = true
	data.RollCount += 1

	DataService.MarkDirty(player)

	QuestService.ReportProgress(player, "RollCount", 1)
	if isNew then
		QuestService.ReportProgress(player, "DiscoverCount", 1)
	end
	AchievementService.Check(player)

	local setBonusGranted = isNew and RollService.CheckSetBonus(player, rarity.Name)

	return {
		Success = true,
		Title = title,
		Rarity = rarity,
		IsNew = isNew,
		PityTriggered = pityTriggered,
		RollsSincePity = data.RollsSincePity,
		NewTreats = data.Treats,
		Cost = cost,
		SetBonusGranted = setBonusGranted,
	}
end

-- Pass titleId = nil to unequip. Equipping requires the title be discovered
-- (or granted directly, e.g. the VIP exclusive) — never trust the client's word alone.
function RollService.EquipTitle(player: Player, titleId: string?): boolean
	local data = DataService.Get(player)
	if not data then
		return false
	end
	if titleId ~= nil and not data.DiscoveredTitles[titleId] then
		return false
	end
	data.EquippedTitle = titleId
	DataService.MarkDirty(player)

	local title
	if titleId then
		for _, t in Titles do
			if t.Id == titleId then
				title = t
				break
			end
		end
	end

	if title then
		local rarity = rarityByName[title.Rarity]
		player:SetAttribute("EquippedTitleName", title.Name)
		player:SetAttribute("EquippedTitleColor", rarity and rarity.Color or Color3.new(1, 1, 1))
	else
		player:SetAttribute("EquippedTitleName", nil)
		player:SetAttribute("EquippedTitleColor", nil)
	end

	return true
end

return RollService
