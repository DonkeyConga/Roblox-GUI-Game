--!strict
-- Populates the built-in Roblox player list (top-right) with Coins/Rebirths.
local DataService = require(script.Parent.DataService)

local LeaderstatsService = {}

function LeaderstatsService.Create(player: Player)
	local data = DataService.Get(player)
	if not data then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "leaderstats"

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = math.floor(data.Coins)
	coins.Parent = folder

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
			coins.Value = math.floor(data.Coins)
			rebirths.Value = data.Rebirths
		end
	end)
end

return LeaderstatsService
