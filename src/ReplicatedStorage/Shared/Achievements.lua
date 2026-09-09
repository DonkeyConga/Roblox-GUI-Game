--!strict
-- Permanent, one-time milestones. Never reset by Rebirth or the daily quest
-- cycle. With 100+ titles across 7 rarities, full completion is a long haul —
-- these give plenty of checkpoints to feel rewarded along the way.
-- Types: RollCount, Rebirths, DiscoverRarity, RaritySet, LoginStreak,
-- IndexPercent, OwnsVIP — see AchievementService.lua for how each is checked.
local Achievements = {
	-- Roll count milestones
	{ Id = "roll_100", Description = "Roll 100 times", Type = "RollCount", Target = 100, Reward = 500 },
	{ Id = "roll_500", Description = "Roll 500 times", Type = "RollCount", Target = 500, Reward = 1500 },
	{ Id = "roll_1000", Description = "Roll 1,000 times", Type = "RollCount", Target = 1000, Reward = 5000 },
	{ Id = "roll_5000", Description = "Roll 5,000 times", Type = "RollCount", Target = 5000, Reward = 20000 },
	{ Id = "roll_10000", Description = "Roll 10,000 times", Type = "RollCount", Target = 10000, Reward = 50000 },
	{ Id = "roll_50000", Description = "Roll 50,000 times", Type = "RollCount", Target = 50000, Reward = 250000 },

	-- Rebirth milestones
	{ Id = "rebirth_1", Description = "Rebirth once", Type = "Rebirths", Target = 1, Reward = 1000 },
	{ Id = "rebirth_3", Description = "Rebirth 3 times", Type = "Rebirths", Target = 3, Reward = 3000 },
	{ Id = "rebirth_5", Description = "Rebirth 5 times", Type = "Rebirths", Target = 5, Reward = 10000 },
	{ Id = "rebirth_10", Description = "Rebirth 10 times", Type = "Rebirths", Target = 10, Reward = 50000 },
	{ Id = "rebirth_20", Description = "Rebirth 20 times", Type = "Rebirths", Target = 20, Reward = 150000 },
	{ Id = "rebirth_50", Description = "Rebirth 50 times", Type = "Rebirths", Target = 50, Reward = 750000 },

	-- First discovery of a rarity tier
	{ Id = "discover_rare", Description = "Discover a Rare title", Type = "DiscoverRarity", Rarity = "Rare", Reward = 400 },
	{ Id = "discover_epic", Description = "Discover an Epic title", Type = "DiscoverRarity", Rarity = "Epic", Reward = 1500 },
	{ Id = "discover_legendary", Description = "Discover a Legendary title", Type = "DiscoverRarity", Rarity = "Legendary", Reward = 5000 },
	{ Id = "discover_mythic", Description = "Discover a Mythic title", Type = "DiscoverRarity", Rarity = "Mythic", Reward = 15000 },
	{ Id = "discover_secret", Description = "Discover a Secret title", Type = "DiscoverRarity", Rarity = "Secret", Reward = 40000 },

	-- Full rarity-tier collections (the Index's hardest long-term goals)
	{ Id = "collect_all_common", Description = "Discover every Common title", Type = "RaritySet", Rarity = "Common", Reward = 3000 },
	{ Id = "collect_all_uncommon", Description = "Discover every Uncommon title", Type = "RaritySet", Rarity = "Uncommon", Reward = 5000 },
	{ Id = "collect_all_rare", Description = "Discover every Rare title", Type = "RaritySet", Rarity = "Rare", Reward = 8000 },
	{ Id = "collect_all_epic", Description = "Discover every Epic title", Type = "RaritySet", Rarity = "Epic", Reward = 15000 },
	{ Id = "collect_all_legendary", Description = "Discover every Legendary title", Type = "RaritySet", Rarity = "Legendary", Reward = 40000 },
	{ Id = "collect_all_mythic", Description = "Discover every Mythic title", Type = "RaritySet", Rarity = "Mythic", Reward = 100000 },
	{ Id = "collect_all_secret", Description = "Discover every Secret title", Type = "RaritySet", Rarity = "Secret", Reward = 500000 },

	-- Overall Index completion percentage (across every non-exclusive title)
	{ Id = "index_25", Description = "Reach 25% Index completion", Type = "IndexPercent", Target = 25, Reward = 3000 },
	{ Id = "index_50", Description = "Reach 50% Index completion", Type = "IndexPercent", Target = 50, Reward = 15000 },
	{ Id = "index_75", Description = "Reach 75% Index completion", Type = "IndexPercent", Target = 75, Reward = 60000 },
	{ Id = "index_100", Description = "Reach 100% Index completion", Type = "IndexPercent", Target = 100, Reward = 1000000 },

	-- Login streak milestones
	{ Id = "streak_7", Description = "Reach a 7-day login streak", Type = "LoginStreak", Target = 7, Reward = 2000 },
	{ Id = "streak_30", Description = "Reach a 30-day login streak", Type = "LoginStreak", Target = 30, Reward = 20000 },
	{ Id = "streak_100", Description = "Reach a 100-day login streak", Type = "LoginStreak", Target = 100, Reward = 200000 },

	-- VIP
	{ Id = "become_vip", Description = "Become a VIP", Type = "OwnsVIP", Reward = 5000 },
}

return Achievements
