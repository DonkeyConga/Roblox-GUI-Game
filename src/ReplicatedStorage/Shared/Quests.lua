--!strict
-- Pool of possible daily quests. Each day, QuestService picks Config.QuestsPerDay
-- of these at random for each player and resets their progress.
local Quests = {
	{ Id = "roll_10", Description = "Roll 10 times", Type = "RollCount", Target = 10, Reward = 150 },
	{ Id = "roll_25", Description = "Roll 25 times", Type = "RollCount", Target = 25, Reward = 350 },
	{ Id = "roll_50", Description = "Roll 50 times", Type = "RollCount", Target = 50, Reward = 700 },
	{ Id = "discover_2", Description = "Discover 2 new titles", Type = "DiscoverCount", Target = 2, Reward = 250 },
	{ Id = "discover_5", Description = "Discover 5 new titles", Type = "DiscoverCount", Target = 5, Reward = 600 },
	{ Id = "earn_500", Description = "Earn 500 coins", Type = "CoinsEarned", Target = 500, Reward = 150 },
	{ Id = "earn_2000", Description = "Earn 2,000 coins", Type = "CoinsEarned", Target = 2000, Reward = 500 },
	{ Id = "roll_100", Description = "Roll 100 times", Type = "RollCount", Target = 100, Reward = 1200 },
	{ Id = "discover_1", Description = "Discover 1 new title", Type = "DiscoverCount", Target = 1, Reward = 120 },
	{ Id = "earn_5000", Description = "Earn 5,000 coins", Type = "CoinsEarned", Target = 5000, Reward = 1000 },
}

return Quests
