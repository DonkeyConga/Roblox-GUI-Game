--!strict
-- A themed replacement for Roblox's default player list (disabled in
-- Init.client.lua). Ranks every player currently in the server by Treats,
-- reading the same replicated `leaderstats` values every client already
-- receives for free — no remotes needed. Refreshes on a timer rather than
-- wiring per-value-changed signals for every player, which is simpler and
-- plenty responsive for a leaderboard. The local player's own row gets a
-- permanent glow so they can always spot themselves in a crowded server.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIFactory = require(ReplicatedStorage.Shared.UIFactory)
local Effects = require(ReplicatedStorage.Shared.Effects)

local LeaderboardPanel = {}
local Theme = UIFactory.Theme

local REFRESH_INTERVAL = 2
local MEDALS = { "🥇", "🥈", "🥉" }

function LeaderboardPanel.Create(parent: Instance)
	local frame = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	UIFactory.Title({
		Text = "👑 Pusheen Leaderboard",
		TextSize = 24,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = frame,
	})

	UIFactory.Label({
		Text = "🐾 Ranked by treats earned — updates automatically.",
		TextColor3 = Theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, 0, 0, 34),
		Parent = frame,
	})

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -58)
	scroll.Position = UDim2.new(0, 0, 0, 58)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.ScrollBarImageColor3 = Theme.Accent
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.Parent = scroll

	local rows: { [Player]: any } = {}

	local function getOrCreateRow(player: Player)
		local existing = rows[player]
		if existing then
			return existing
		end

		local row = UIFactory.Card({
			Size = UDim2.new(1, 0, 0, 64),
			Parent = scroll,
		})
		if player == Players.LocalPlayer then
			UIFactory.UpgradeCardGlow(row, Theme.Accent, 2)
		end

		local rankLabel = UIFactory.Title({
			Text = "#0",
			TextSize = 20,
			Size = UDim2.new(0, 56, 1, 0),
			Position = UDim2.new(0, 12, 0, 0),
			Parent = row,
		})

		local nameLabel = UIFactory.Label({
			Text = player.Name,
			Font = Theme.Font,
			TextSize = 17,
			Size = UDim2.new(0, 220, 0, 22),
			Position = UDim2.new(0, 76, 0, 10),
			Parent = row,
		})

		local titleTagLabel = UIFactory.Label({
			Text = "",
			Font = Theme.FontMedium,
			TextSize = 13,
			TextColor3 = Theme.SubText,
			Size = UDim2.new(0, 260, 0, 16),
			Position = UDim2.new(0, 76, 0, 34),
			Parent = row,
		})

		local treatsLabel = UIFactory.Label({
			Text = "🐟 0",
			Font = Theme.FontDisplay,
			TextColor3 = Theme.Accent,
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.new(0, 140, 1, 0),
			Position = UDim2.new(1, -320, 0, 0),
			Parent = row,
		})

		local rebirthsLabel = UIFactory.Label({
			Text = "✦ 0",
			Font = Theme.FontDisplay,
			TextColor3 = Theme.Violet,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.new(0, 160, 1, 0),
			Position = UDim2.new(1, -170, 0, 0),
			Parent = row,
		})

		local rowData = {
			Row = row,
			RankLabel = rankLabel,
			NameLabel = nameLabel,
			TitleTagLabel = titleTagLabel,
			TreatsLabel = treatsLabel,
			RebirthsLabel = rebirthsLabel,
		}
		rows[player] = rowData
		return rowData
	end

	local function refresh()
		local ranked = {}
		for _, player in Players:GetPlayers() do
			local stats = player:FindFirstChild("leaderstats")
			local treatsValue = stats and stats:FindFirstChild("Treats")
			local rebirthsValue = stats and stats:FindFirstChild("Rebirths")
			if treatsValue then
				table.insert(ranked, {
					Player = player,
					Treats = (treatsValue :: IntValue).Value,
					Rebirths = if rebirthsValue then (rebirthsValue :: IntValue).Value else 0,
				})
			end
		end
		table.sort(ranked, function(a, b)
			return a.Treats > b.Treats
		end)

		local seen: { [Player]: boolean } = {}
		for i, entry in ranked do
			seen[entry.Player] = true
			local rowData = getOrCreateRow(entry.Player)
			rowData.Row.LayoutOrder = i
			rowData.RankLabel.Text = MEDALS[i] or ("#" .. i)
			rowData.TreatsLabel.Text = "🐟 " .. Effects.FormatNumber(entry.Treats)
			rowData.RebirthsLabel.Text = "✦ " .. tostring(entry.Rebirths)

			local equippedName = entry.Player:GetAttribute("EquippedTitleName")
			local equippedColor = entry.Player:GetAttribute("EquippedTitleColor")
			rowData.TitleTagLabel.Text = equippedName or ""
			rowData.TitleTagLabel.TextColor3 = equippedColor or Theme.SubText
		end

		-- Drop rows for players who've since left the server.
		for player, rowData in rows do
			if not seen[player] then
				rowData.Row:Destroy()
				rows[player] = nil
			end
		end
	end

	task.spawn(function()
		while frame.Parent do
			refresh()
			task.wait(REFRESH_INTERVAL)
		end
	end)

	return frame
end

return LeaderboardPanel
