--!strict
-- Permanent, one-time milestones. Never reset by Rebirth or the daily quest cycle.
local Achievements = {
	{ Id = "roll_100", Description = "Roll 100 times", Type = "RollCount", Target = 100, Reward = 500 },
	{ Id = "roll_1000", Description = "Roll 1,000 times", Type = "RollCount", Target = 1000, Reward = 5000 },
	{ Id = "roll_10000", Description = "Roll 10,000 times", Type = "RollCount", Target = 10000, Reward = 50000 },
	{ Id = "rebirth_1", Description = "Rebirth once", Type = "Rebirths", Target = 1, Reward = 1000 },
	{ Id = "rebirth_5", Description = "Rebirth 5 times", Type = "Rebirths", Target = 5, Reward = 10000 },
	{ Id = "rebirth_10", Description = "Rebirth 10 times", Type = "Rebirths", Target = 10, Reward = 50000 },
	{ Id = "discover_mythic", Description = "Discover a Mythic title", Type = "DiscoverRarity", Rarity = "Mythic", Reward = 5000 },
	{ Id = "discover_secret", Description = "Discover a Secret title", Type = "DiscoverRarity", Rarity = "Secret", Reward = 15000 },
	{ Id = "collect_all_common", Description = "Discover every Common title", Type = "RaritySet", Rarity = "Common", Reward = 2000 },
	{ Id = "collect_all_uncommon", Description = "Discover every Uncommon title", Type = "RaritySet", Rarity = "Uncommon", Reward = 3000 },
}

return Achievements
