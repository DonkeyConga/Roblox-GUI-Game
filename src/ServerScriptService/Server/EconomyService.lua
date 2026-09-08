--!strict
-- Passive coin income: a per-second tick for online players, plus a one-time
-- AFK grant on join covering the time they were away (capped and discounted).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local DataService = require(script.Parent.DataService)
local RollService = require(script.Parent.RollService)
local QuestService = require(script.Parent.QuestService)

local EconomyService = {}

function EconomyService.GrantAFKGains(player: Player): number
	local data = DataService.Get(player)
	if not data then
		return 0
	end
	if data.LastSeen <= 0 then
		data.LastSeen = os.time()
		return 0
	end

	local elapsed = math.clamp(os.time() - data.LastSeen, 0, Config.MaxAFKSeconds)
	if elapsed <= 0 then
		return 0
	end

	local rate = Config.BaseIdleCoinsPerSecond * RollService.GetCoinMultiplier(data)
	local gained = math.floor(elapsed * rate * Config.AFKEfficiency)
	if gained > 0 then
		data.Coins += gained
		QuestService.ReportProgress(player, "CoinsEarned", gained)
		DataService.MarkDirty(player)
	end
	return gained
end

function EconomyService.Init()
	task.spawn(function()
		while true do
			task.wait(1)
			for _, player in Players:GetPlayers() do
				local data = DataService.Get(player)
				if data then
					local rate = Config.BaseIdleCoinsPerSecond * RollService.GetCoinMultiplier(data)
					data.Coins += rate
					QuestService.ReportProgress(player, "CoinsEarned", rate)
					data.LastSeen = os.time()
				end
			end
		end
	end)
end

return EconomyService
