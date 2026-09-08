--!strict
-- Owns loading, saving, and in-memory access to each player's save data.
-- Every other server service reads/writes through DataService.Get(player)'s
-- returned table by reference, then calls MarkDirty so autosave picks it up.
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local DataService = {}

local store = DataStoreService:GetDataStore(Config.DataStoreName)
local profiles: { [Player]: any } = {}
local dirty: { [Player]: boolean } = {}

local function defaultData()
	return {
		Coins = Config.StartingCoins,
		Rebirths = 0,
		EquippedTitle = nil :: string?,
		DiscoveredTitles = {} :: { [string]: boolean },
		RollCount = 0,
		RollsSincePity = 0,
		AutoRollEnabled = false,
		LastLoginDate = "" :: string,
		LoginStreak = 0,
		OwnsVIP = false,
		SetBonuses = {} :: { [string]: boolean },
		LastSeen = 0,
		Quests = {
			Date = "" :: string,
			Active = {} :: { string },
			Progress = {} :: { [string]: number },
			Claimed = {} :: { [string]: boolean },
		},
		Achievements = {} :: { [string]: boolean },
	}
end

-- Fills in any fields missing from an older save (e.g. after adding a new
-- system) without clobbering the player's existing progress.
local function reconcile(data, defaults)
	for key, value in defaults do
		if data[key] == nil then
			data[key] = value
		elseif typeof(value) == "table" and typeof(data[key]) == "table" then
			reconcile(data[key], value)
		end
	end
	return data
end

function DataService.Load(player: Player)
	local key = "Player_" .. player.UserId
	local success, result = pcall(function()
		return store:GetAsync(key)
	end)

	local data
	if success and result then
		data = reconcile(result, defaultData())
	else
		data = defaultData()
	end

	profiles[player] = data
	return data
end

function DataService.Get(player: Player)
	return profiles[player]
end

function DataService.MarkDirty(player: Player)
	dirty[player] = true
end

function DataService.Save(player: Player)
	local data = profiles[player]
	if not data then
		return
	end
	local key = "Player_" .. player.UserId
	local success, err = pcall(function()
		store:SetAsync(key, data)
	end)
	if success then
		dirty[player] = nil
	else
		warn(`[DataService] Failed to save data for {player.Name}: {err}`)
	end
end

function DataService.Release(player: Player)
	if dirty[player] then
		DataService.Save(player)
	end
	profiles[player] = nil
	dirty[player] = nil
end

function DataService.Init()
	task.spawn(function()
		while true do
			task.wait(Config.AutosaveInterval)
			for player in dirty do
				if profiles[player] then
					DataService.Save(player)
				end
			end
		end
	end)

	game:BindToClose(function()
		if RunService:IsStudio() then
			return
		end
		for _, player in Players:GetPlayers() do
			DataService.Save(player)
		end
	end)
end

return DataService
