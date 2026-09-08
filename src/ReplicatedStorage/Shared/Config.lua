--!strict
-- Central tuning knobs for the whole game. Change numbers here to rebalance.
local Config = {}

Config.StartingCoins = 0

Config.BaseRollCost = 50
Config.RollCostGrowthPerRebirth = 1.35 -- roll cost multiplies by this every rebirth

Config.BaseIdleCoinsPerSecond = 1

Config.PityRollThreshold = 40 -- guaranteed Epic+ roll after this many rolls without one
Config.PityMinRarityIndex = 4 -- Rarities[4] = "Epic" — see Rarities.lua

Config.BaseRebirthRequirement = 2500
Config.RebirthRequirementGrowth = 2.15 -- coin requirement multiplies by this every rebirth

Config.RebirthCoinBonusPerRebirth = 0.15 -- +15% coin gain per rebirth
Config.RebirthLuckBonusPerRebirth = 0.05 -- +5% luck per rebirth

Config.SetBonusLuckBonus = 0.03 -- +3% luck per fully-collected rarity tier in the Index

Config.AutoRollInterval = 1.5 -- seconds between automatic rolls
Config.AutoRollUnlockRebirths = 3 -- free players unlock Auto-Roll at this rebirth count

Config.MaxAFKSeconds = 4 * 60 * 60 -- offline earnings cap: 4 hours
Config.AFKEfficiency = 0.5 -- offline coins accrue at 50% of the online idle rate

Config.VIPCoinMultiplier = 2
Config.VIPLuckMultiplier = 1.25

-- Reward for each consecutive login day. Loops back to the start after the list ends.
Config.DailyStreakRewards = { 100, 150, 200, 300, 400, 600, 1000 }

Config.QuestsPerDay = 3

Config.GamepassIds = {
	-- TODO: replace with your real Gamepass asset id from the Roblox Creator Dashboard.
	-- Left at 0, VIP purchases are safely disabled (no errors, just a no-op prompt).
	VIP = 0,
}

Config.DataStoreName = "TitleRollRNG_PlayerData_v1"
Config.AutosaveInterval = 60 -- seconds

return Config
