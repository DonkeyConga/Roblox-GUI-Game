--!strict
-- Rebirth: sacrifice all current treats for a permanent treat/luck multiplier.
-- Titles, the Index, quests, and achievements are untouched — only currency resets.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local DataService = require(script.Parent.DataService)
local AchievementService = require(script.Parent.AchievementService)

local RebirthService = {}

function RebirthService.GetRequirement(data): number
	return math.floor(Config.BaseRebirthRequirement * (Config.RebirthRequirementGrowth ^ data.Rebirths))
end

function RebirthService.PerformRebirth(player: Player)
	local data = DataService.Get(player)
	if not data then
		return { Success = false }
	end
	local requirement = RebirthService.GetRequirement(data)
	if data.Treats < requirement then
		return { Success = false, Reason = "NotEnoughTreats", Requirement = requirement }
	end

	data.Treats = 0
	data.Rebirths += 1
	data.AutoRollEnabled = false
	DataService.MarkDirty(player)

	AchievementService.Check(player)

	return {
		Success = true,
		Rebirths = data.Rebirths,
		NextRequirement = RebirthService.GetRequirement(data),
	}
end

return RebirthService
