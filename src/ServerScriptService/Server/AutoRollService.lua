--!strict
-- Auto-Roll: once unlocked (VIP, or free at Config.AutoRollUnlockRebirths), the
-- player can toggle a loop that rolls for them every Config.AutoRollInterval
-- seconds as long as they can afford it, animating each result on the client.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)
local Remotes = require(ReplicatedStorage.Shared.RemoteEvents)

local DataService = require(script.Parent.DataService)
local RollService = require(script.Parent.RollService)

local AutoRollService = {}

local rollResultEvent = Remotes.GetEvent("RollResult")
local running: { [Player]: boolean } = {}

function AutoRollService.CanUseAutoRoll(data): boolean
	return data.OwnsVIP or data.Rebirths >= Config.AutoRollUnlockRebirths
end

function AutoRollService.SetEnabled(player: Player, enabled: boolean): boolean
	local data = DataService.Get(player)
	if not data then
		return false
	end
	if enabled and not AutoRollService.CanUseAutoRoll(data) then
		return false
	end

	data.AutoRollEnabled = enabled
	DataService.MarkDirty(player)

	if enabled and not running[player] then
		running[player] = true
		task.spawn(function()
			while running[player] and data.AutoRollEnabled and player.Parent do
				task.wait(Config.AutoRollInterval)
				if not data.AutoRollEnabled or not player.Parent then
					break
				end
				local result = RollService.PerformRoll(player)
				if result.Success then
					rollResultEvent:FireClient(player, result)
				else
					data.AutoRollEnabled = false
					DataService.MarkDirty(player)
					break
				end
			end
			running[player] = nil
		end)
	end

	return true
end

function AutoRollService.Stop(player: Player)
	running[player] = nil
	local data = DataService.Get(player)
	if data then
		data.AutoRollEnabled = false
	end
end

return AutoRollService
