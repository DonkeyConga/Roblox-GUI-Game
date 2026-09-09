--!strict
-- Populates a leaderstats folder (Treats/Rebirths) on the player. Roblox's
-- default player-list rendering of this is turned off client-side (see
-- Init.client.lua) in favor of the themed LeaderboardPanel, but the folder
-- itself stays — it's the zero-cost convention other tools/analytics expect,
-- and LeaderboardPanel reads these same replicated values directly.
local DataService = require(script.Parent.DataService)

local LeaderstatsService = {}

function LeaderstatsService.Create(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"

	local treats = Instance.new("IntValue")
	treats.Name = "Treats"
	treats.Value = math.floor(data.Treats)
	treats.Parent = folder

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = data.Rebirths
	rebirths.Parent = folder

	folder.Parent = player

	task.spawn(function()
		while player.Parent and DataService.Get(player) do
			task.wait(1)
			if not DataService.Get(player) then
				break
			end
			treats.Value = math.floor(data.Treats)
			rebirths.Value = data.Rebirths
		end
	end)
end

return LeaderstatsService
