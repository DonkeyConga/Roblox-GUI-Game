--!strict
-- Daily login streak. Peek() computes what the player would get (used to show
-- the popup on join without mutating anything); Claim() actually commits it.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local DataService = require(script.Parent.DataService)

local StreakService = {}

local function today(): string
	return os.date("!%Y-%m-%d")
end

local function yesterday(): string
	return os.date("!%Y-%m-%d", os.time() - 86400)
end

local function rewardForStreak(streak: number): number
	local index = ((streak - 1) % #Config.DailyStreakRewards) + 1
	return Config.DailyStreakRewards[index]
end

-- Returns { Day, Reward } if the player hasn't claimed today yet, else nil.
function StreakService.Peek(player: Player)
	local data = DataService.Get(player)
	if not data then
		return nil
	end
	if data.LastLoginDate == today() then
		return nil
	end
	local nextStreak = (data.LastLoginDate == yesterday()) and (data.LoginStreak + 1) or 1
	return { Day = nextStreak, Reward = rewardForStreak(nextStreak) }
end

function StreakService.Claim(player: Player)
	local data = DataService.Get(player)
	if not data then
		return { Success = false }
	end
	if data.LastLoginDate == today() then
		return { Success = false, Reason = "AlreadyClaimed" }
	end

	data.LoginStreak = (data.LastLoginDate == yesterday()) and (data.LoginStreak + 1) or 1
	data.LastLoginDate = today()

	local reward = rewardForStreak(data.LoginStreak)
	data.Treats += reward
	DataService.MarkDirty(player)

	return { Success = true, Day = data.LoginStreak, Reward = reward, NewTreats = data.Treats }
end

return StreakService
