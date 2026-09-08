--!strict
-- Builds the whole ScreenGui: top bar, bottom nav, and the five panels.
-- Owns the single `state` table that every panel reads from and that
-- DataSync keeps up to date in place.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIFactory = require(ReplicatedStorage.Shared.UIFactory)
local Titles = require(ReplicatedStorage.Shared.Titles)
local Rarities = require(ReplicatedStorage.Shared.Rarities)

local RollPanel = require(script.Parent.RollPanel)
local IndexPanel = require(script.Parent.IndexPanel)
local RebirthPanel = require(script.Parent.RebirthPanel)
local ShopPanel = require(script.Parent.ShopPanel)
local QuestPanel = require(script.Parent.QuestPanel)
local DailyRewardPopup = require(script.Parent.DailyRewardPopup)
local Notification = require(script.Parent.Notification)

local MainUI = {}
local Theme = UIFactory.Theme

local titleById = {}
for _, title in Titles do
	titleById[title.Id] = title
end
local rarityByName = {}
for _, rarity in Rarities do
	rarityByName[rarity.Name] = rarity
end

function MainUI.FormatNumber(n: number): string
	n = math.floor(n)
	if n >= 1e12 then
		return string.format("%.2fT", n / 1e12)
	elseif n >= 1e9 then
		return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.2fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.2fK", n / 1e3)
	end
	return tostring(n)
end

function MainUI.Init(player: Player, RemoteController)
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	local state = {
		Coins = 0,
		Rebirths = 0,
		EquippedTitle = nil,
		DiscoveredTitles = {},
		RollCount = 0,
		RollsSincePity = 0,
		AutoRollEnabled = false,
		LoginStreak = 0,
		OwnsVIP = false,
		SetBonuses = {},
		Achievements = {},
		Quests = {},
		RollCost = 0,
		RebirthRequirement = 0,
		CanAutoRoll = false,
	}

	-- Top bar
	local topBar = UIFactory.Frame({
		Size = UDim2.new(1, 0, 0, 56),
		BackgroundColor3 = Theme.Background,
		Parent = screenGui,
	})
	UIFactory.Padding(10).Parent = topBar
	local topLayout = Instance.new("UIListLayout")
	topLayout.FillDirection = Enum.FillDirection.Horizontal
	topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	topLayout.Padding = UDim.new(0, 16)
	topLayout.Parent = topBar

	local coinsLabel = UIFactory.Label({
		Text = "🪙 0",
		Font = Theme.Font,
		TextSize = 20,
		Size = UDim2.new(0, 160, 1, 0),
		Parent = topBar,
	})

	local rebirthsLabel = UIFactory.Label({
		Text = "✦ Rebirths: 0",
		Font = Theme.Font,
		TextSize = 20,
		Size = UDim2.new(0, 200, 1, 0),
		Parent = topBar,
	})

	local titleLabel = UIFactory.Label({
		Text = "No Title Equipped",
		Font = Theme.FontRegular,
		TextSize = 16,
		TextColor3 = Theme.SubText,
		Size = UDim2.new(0, 320, 1, 0),
		Parent = topBar,
	})

	-- Panel container + bottom nav
	local panelContainer = UIFactory.Frame({
		Size = UDim2.new(1, -40, 1, -170),
		Position = UDim2.new(0, 20, 0, 66),
		BackgroundTransparency = 1,
		Parent = screenGui,
	})

	local navBar = UIFactory.Frame({
		Size = UDim2.new(1, -40, 0, 64),
		Position = UDim2.new(0, 20, 1, -74),
		BackgroundColor3 = Theme.Background,
		Parent = screenGui,
	})
	UIFactory.Corner(14).Parent = navBar
	UIFactory.Padding(8).Parent = navBar
	local navLayout = Instance.new("UIListLayout")
	navLayout.FillDirection = Enum.FillDirection.Horizontal
	navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	navLayout.Padding = UDim.new(0, 10)
	navLayout.Parent = navBar

	local notification = Notification.Create(screenGui)

	local panels = {}
	local navButtons = {}

	local function showPanel(name: string)
		for panelName, panelFrame in panels do
			panelFrame.Visible = (panelName == name)
		end
		for navName, button in navButtons do
			button.BackgroundColor3 = (navName == name) and Theme.Accent or Theme.PanelLight
		end
	end

	local function addNavButton(name: string, icon: string)
		local button = UIFactory.Button({
			Text = icon .. " " .. name,
			Size = UDim2.new(0, 140, 1, -8),
			BackgroundColor3 = Theme.PanelLight,
			Parent = navBar,
		})
		button.MouseButton1Click:Connect(function()
			showPanel(name)
		end)
		navButtons[name] = button
	end

	addNavButton("Roll", "🎲")
	addNavButton("Index", "📖")
	addNavButton("Rebirth", "✦")
	addNavButton("Shop", "🛒")
	addNavButton("Quests", "📜")

	panels["Roll"] = RollPanel.Create(panelContainer, state, RemoteController, notification)
	panels["Index"] = IndexPanel.Create(panelContainer, state, RemoteController, notification)
	panels["Rebirth"] = RebirthPanel.Create(panelContainer, state, RemoteController, notification)
	panels["Shop"] = ShopPanel.Create(panelContainer, state, RemoteController, notification)
	panels["Quests"] = QuestPanel.Create(panelContainer, state, RemoteController, notification)

	showPanel("Roll")

	local dailyRewardPopup = DailyRewardPopup.Create(screenGui, RemoteController)

	local function refreshTopBar()
		coinsLabel.Text = "🪙 " .. MainUI.FormatNumber(state.Coins)
		rebirthsLabel.Text = "✦ Rebirths: " .. tostring(state.Rebirths)

		local title = state.EquippedTitle and titleById[state.EquippedTitle]
		if title then
			local rarity = rarityByName[title.Rarity]
			titleLabel.Text = player.Name .. " " .. title.Name
			titleLabel.TextColor3 = rarity and rarity.Color or Theme.SubText
		else
			titleLabel.Text = "No Title Equipped"
			titleLabel.TextColor3 = Theme.SubText
		end
	end

	RemoteController.OnDataSync:Connect(function(data)
		for key, value in data do
			state[key] = value
		end
		refreshTopBar()
		RollPanel.Refresh(state)
		IndexPanel.Refresh(state)
		RebirthPanel.Refresh(state)
		ShopPanel.Refresh(state)
		QuestPanel.Refresh(state)
	end)

	RemoteController.OnNotify:Connect(function(payload)
		notification.Show(payload.Message, payload.Type)
	end)

	RemoteController.OnShowDailyReward:Connect(function(info)
		dailyRewardPopup.Show(info)
	end)

	RemoteController.OnRollResult:Connect(function(result)
		RollPanel.PlayRollResult(result)
	end)
end

return MainUI
