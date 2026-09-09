--!strict
-- Builds the whole ScreenGui: ambient backdrop, an edge-to-edge top bar, a
-- floating bottom nav with a sliding highlight pill, and the six panels
-- filling the entire space between them. Owns the single `state` table that
-- every panel reads from and that DataSync (or the RequestSync pull below)
-- keeps up to date in place.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIFactory = require(ReplicatedStorage.Shared.UIFactory)
local Effects = require(ReplicatedStorage.Shared.Effects)
local Titles = require(ReplicatedStorage.Shared.Titles)
local Rarities = require(ReplicatedStorage.Shared.Rarities)

local RollPanel = require(script.Parent.RollPanel)
local IndexPanel = require(script.Parent.IndexPanel)
local RebirthPanel = require(script.Parent.RebirthPanel)
local ShopPanel = require(script.Parent.ShopPanel)
local QuestPanel = require(script.Parent.QuestPanel)
local LeaderboardPanel = require(script.Parent.LeaderboardPanel)
local DailyRewardPopup = require(script.Parent.DailyRewardPopup)
local Notification = require(script.Parent.Notification)

local MainUI = {}
local Theme = UIFactory.Theme

local TOP_BAR_HEIGHT = 72
local NAV_HEIGHT = 68
local NAV_MARGIN = 16 -- the nav bar floats a small distance off the very bottom/sides

local titleById = {}
for _, title in Titles do
	titleById[title.Id] = title
end
local rarityByName = {}
for _, rarity in Rarities do
	rarityByName[rarity.Name] = rarity
end

function MainUI.Init(player: Player, RemoteController)
	local playerGui = player:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui

	UIFactory.Backdrop(screenGui)

	local state = {
		Treats = 0,
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

	-- Top bar: full-width, edge-to-edge, with a soft elevation shadow cast
	-- into the content below and a gently-bobbing paw icon for cuteness.
	local topBar = UIFactory.Frame({
		Size = UDim2.new(1, 0, 0, TOP_BAR_HEIGHT),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Theme.Panel,
		Parent = screenGui,
	})
	UIFactory.Gradient(ColorSequence.new(Theme.PanelTop, Theme.Panel), 90).Parent = topBar
	UIFactory.Padding(16).Parent = topBar

	UIFactory.Frame({
		Size = UDim2.new(1, 0, 0, 3),
		Position = UDim2.new(0, 0, 1, -3),
		BackgroundColor3 = Theme.Accent,
		Parent = topBar,
	})

	local topBarShadow = UIFactory.Frame({
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.78,
		Parent = topBar,
	})
	UIFactory.Gradient(ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)), 90).Parent = topBarShadow
	local topBarShadowGradient = topBarShadow:FindFirstChildOfClass("UIGradient") :: UIGradient
	topBarShadowGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})

	local topLayout = Instance.new("UIListLayout")
	topLayout.FillDirection = Enum.FillDirection.Horizontal
	topLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	topLayout.Padding = UDim.new(0, 24)
	topLayout.Parent = topBar

	-- Bobbing the label's own Position wouldn't work here — it's a direct
	-- child of topBar's UIListLayout, which recalculates Position every
	-- frame and would fight the tween. An unmanaged wrapper frame isolates
	-- the animated child from that layout entirely.
	local pawWrapper = UIFactory.Frame({
		Size = UDim2.new(0, 32, 0, 32),
		BackgroundTransparency = 1,
		Parent = topBar,
	})
	local pawIcon = UIFactory.Label({
		Text = "🐾",
		TextSize = 26,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = pawWrapper,
	})
	Effects.Bob(pawIcon, 3, 1.4)

	local treatsLabel = UIFactory.Label({
		Text = "🐟 0",
		Font = Theme.FontDisplay,
		TextColor3 = Theme.Accent,
		TextSize = 26,
		Size = UDim2.new(0, 170, 1, 0),
		Parent = topBar,
	})

	local rebirthsLabel = UIFactory.Label({
		Text = "✦ Rebirths: 0",
		Font = Theme.FontDisplay,
		TextColor3 = Theme.Violet,
		TextSize = 22,
		Size = UDim2.new(0, 210, 1, 0),
		Parent = topBar,
	})

	local titleLabel = UIFactory.Label({
		Text = "No Title Equipped",
		Font = Theme.FontMedium,
		TextSize = 18,
		TextColor3 = Theme.SubText,
		Size = UDim2.new(0, 360, 1, 0),
		Parent = topBar,
	})

	-- Panel container fills the entire space between the top bar and the
	-- floating nav — full width, no side margins, so every panel gets the
	-- whole screen to work with.
	local panelContainer = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, -(TOP_BAR_HEIGHT + NAV_HEIGHT + NAV_MARGIN)),
		Position = UDim2.new(0, 0, 0, TOP_BAR_HEIGHT),
		BackgroundTransparency = 1,
		Parent = screenGui,
	})

	-- Floating bottom nav: a small margin on all sides so its rounded card
	-- reads as a deliberate floating pill rather than a bar clipped by the
	-- screen edge.
	local navBar = UIFactory.Card({
		Size = UDim2.new(1, -NAV_MARGIN * 2, 0, NAV_HEIGHT),
		Position = UDim2.new(0, NAV_MARGIN, 1, -(NAV_HEIGHT + NAV_MARGIN)),
		Parent = screenGui,
	})
	UIFactory.Padding(8).Parent = navBar

	-- The sliding highlight pill lives directly in navBar (NOT inside the
	-- button row below), so the row's UIListLayout never tries to arrange it
	-- as another button. Its ZIndex keeps it behind the button row.
	local navPill = Instance.new("Frame")
	navPill.BackgroundColor3 = Theme.AccentDark
	navPill.BorderSizePixel = 0
	navPill.ZIndex = 1
	navPill.Parent = navBar
	UIFactory.Corner(10).Parent = navPill
	UIFactory.Gradient(
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.AccentPale),
			ColorSequenceKeypoint.new(0.55, Theme.Accent),
			ColorSequenceKeypoint.new(1, Theme.AccentDark),
		}),
		90
	).Parent = navPill

	local navButtonRow = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = navBar,
	})
	local navLayout = Instance.new("UIListLayout")
	navLayout.FillDirection = Enum.FillDirection.Horizontal
	navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	navLayout.Padding = UDim.new(0, 10)
	navLayout.Parent = navButtonRow

	local notification = Notification.Create(screenGui)

	local panels = {}
	local tabSetters = {}
	local tabButtons: { [string]: TextButton } = {}

	local function movePillTo(name: string, animate: boolean)
		local button = tabButtons[name]
		if not button then
			return
		end
		local targetPosition = UDim2.new(
			0,
			button.AbsolutePosition.X - navBar.AbsolutePosition.X,
			0,
			button.AbsolutePosition.Y - navBar.AbsolutePosition.Y
		)
		local targetSize = UDim2.new(0, button.AbsoluteSize.X, 0, button.AbsoluteSize.Y)
		if animate then
			TweenService:Create(
				navPill,
				TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
				{ Position = targetPosition, Size = targetSize }
			):Play()
		else
			navPill.Position = targetPosition
			navPill.Size = targetSize
		end
	end

	local function showPanel(name: string, animatePill: boolean?)
		for panelName, panelFrame in panels do
			panelFrame.Visible = (panelName == name)
		end
		local shownFrame = panels[name]
		if shownFrame then
			Effects.PopIn(shownFrame)
		end
		for tabName, setActive in tabSetters do
			setActive(tabName == name)
		end
		movePillTo(name, animatePill ~= false)
	end

	local function addTabButton(name: string, icon: string)
		local button = UIFactory.TabButton({
			Text = icon .. "  " .. name,
			Size = UDim2.new(0, 140, 1, -8),
			Parent = navButtonRow,
		})
		button.MouseButton1Click:Connect(function()
			showPanel(name)
		end)
		tabSetters[name] = function(active: boolean)
			UIFactory.SetTabActive(button, active)
		end
		tabButtons[name] = button
	end

	addTabButton("Roll", "🎲")
	addTabButton("Index", "🐱")
	addTabButton("Rebirth", "✦")
	addTabButton("Shop", "🛍️")
	addTabButton("Quests", "📜")
	addTabButton("Leaders", "👑")

	panels["Roll"] = RollPanel.Create(panelContainer, state, RemoteController, notification)
	panels["Index"] = IndexPanel.Create(panelContainer, state, RemoteController, notification)
	panels["Rebirth"] = RebirthPanel.Create(panelContainer, state, RemoteController, notification)
	panels["Shop"] = ShopPanel.Create(panelContainer, state, RemoteController, notification)
	panels["Quests"] = QuestPanel.Create(panelContainer, state, RemoteController, notification)
	panels["Leaders"] = LeaderboardPanel.Create(panelContainer)

	showPanel("Roll", false)
	-- AbsolutePosition/AbsoluteSize on brand-new UIListLayout children aren't
	-- reliable until at least one layout pass has happened; defer one extra
	-- snap so the pill lands in the right place on first load instead of
	-- wherever it guessed before the row was actually laid out.
	task.defer(function()
		movePillTo("Roll", false)
	end)

	local dailyRewardPopup = DailyRewardPopup.Create(screenGui, RemoteController, notification)

	local function refreshTopBar(previousTreats: number?, previousRebirths: number?)
		if previousTreats ~= nil and previousTreats ~= state.Treats then
			Effects.CountUpNumber(treatsLabel, previousTreats, state.Treats, function(n)
				return "🐟 " .. Effects.FormatNumber(n)
			end, 0.5)
		else
			treatsLabel.Text = "🐟 " .. Effects.FormatNumber(state.Treats)
		end

		if previousRebirths ~= nil and previousRebirths ~= state.Rebirths then
			Effects.CountUpNumber(rebirthsLabel, previousRebirths, state.Rebirths, function(n)
				return "✦ Rebirths: " .. tostring(math.floor(n))
			end, 0.5)
		else
			rebirthsLabel.Text = "✦ Rebirths: " .. tostring(state.Rebirths)
		end

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

	local function applySync(data)
		local previousTreats = state.Treats
		local previousRebirths = state.Rebirths
		for key, value in data do
			state[key] = value
		end
		refreshTopBar(previousTreats, previousRebirths)
		RollPanel.Refresh(state)
		IndexPanel.Refresh(state)
		RebirthPanel.Refresh(state)
		ShopPanel.Refresh(state)
		QuestPanel.Refresh(state)
	end

	RemoteController.OnDataSync:Connect(applySync)

	RemoteController.OnNotify:Connect(function(payload)
		notification.Show(payload.Message, payload.Type)
	end)

	RemoteController.OnShowDailyReward:Connect(function(info)
		dailyRewardPopup.Show(info)
	end)

	RemoteController.OnRollResult:Connect(function(result)
		RollPanel.PlayRollResult(result)
	end)

	-- The join-time DataSync push from the server is fire-and-forget: if this
	-- client wasn't listening yet when it fired, that payload is gone for
	-- good. Now that every listener above is wired up, pull the current data
	-- directly so the UI is always correct regardless of how that race went.
	task.spawn(function()
		local initialData = RemoteController.RequestSync()
		if initialData then
			applySync(initialData)
		end
	end)
end

return MainUI
