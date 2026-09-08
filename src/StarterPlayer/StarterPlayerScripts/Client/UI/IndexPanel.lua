--!strict
-- Collection log: every title grouped by rarity, "???" until discovered.
-- Tap a discovered title to equip it (tap again to unequip). state is the
-- same mutable table MainUI feeds from DataSync, so click handlers can read
-- current discovery/equip status live without waiting for a fresh Refresh.
-- Discovered entries get a permanent rarity-tinted border; the currently
-- equipped one gets a full pulsing glow (a cycling rainbow for Secret titles).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIFactory = require(ReplicatedStorage.Shared.UIFactory)
local Titles = require(ReplicatedStorage.Shared.Titles)
local Rarities = require(ReplicatedStorage.Shared.Rarities)

local IndexPanel = {}
local Theme = UIFactory.Theme

function IndexPanel.Create(parent: Instance, state, RemoteController, notification)
	local frame = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	local header = UIFactory.Title({
		Text = "Title Index — 0%",
		TextSize = 24,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = frame,
	})

	UIFactory.Label({
		Text = "Tap a discovered title to equip it. Tap again to unequip.",
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
	listLayout.Padding = UDim.new(0, 14)
	listLayout.Parent = scroll

	local entryByTitleId = {}

	for _, rarity in Rarities do
		local section = UIFactory.Frame({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Parent = scroll,
		})
		local sectionLayout = Instance.new("UIListLayout")
		sectionLayout.Padding = UDim.new(0, 6)
		sectionLayout.Parent = section

		UIFactory.Label({
			Text = rarity.Name,
			Font = Theme.Font,
			TextSize = 18,
			TextColor3 = rarity.Color,
			Size = UDim2.new(1, 0, 0, 24),
			Parent = section,
		})

		UIFactory.Frame({
			Size = UDim2.new(1, 0, 0, 2),
			BackgroundColor3 = rarity.Color,
			BackgroundTransparency = 0.4,
			Parent = section,
		})

		local grid = UIFactory.Frame({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 8),
			Parent = section,
		})
		local gridLayout = Instance.new("UIGridLayout")
		gridLayout.CellSize = UDim2.new(0, 200, 0, 40)
		gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
		gridLayout.Parent = grid

		for _, title in Titles do
			if title.Rarity == rarity.Name then
				local entry = Instance.new("TextButton")
				entry.Text = ""
				entry.AutoButtonColor = false
				entry.BackgroundColor3 = Theme.PanelLight
				entry.BorderSizePixel = 0
				entry.Parent = grid
				UIFactory.Corner(8).Parent = entry

				local stroke = Instance.new("UIStroke")
				stroke.Thickness = 2
				stroke.Color = rarity.Color
				stroke.Transparency = 0.92
				stroke.Parent = entry

				local label = UIFactory.Label({
					Text = "???",
					TextXAlignment = Enum.TextXAlignment.Center,
					Size = UDim2.new(1, -10, 1, 0),
					Position = UDim2.new(0, 5, 0, 0),
					TextColor3 = Theme.SubText,
					Parent = entry,
				})

				entry.MouseButton1Click:Connect(function()
					if not state.DiscoveredTitles[title.Id] then
						return
					end
					local isEquipped = state.EquippedTitle == title.Id
					local result = RemoteController.EquipTitle(if isEquipped then nil else title.Id)
					if result.Success and not isEquipped then
						notification.Show(`Equipped {title.Name}`, "Success")
					end
				end)

				entryByTitleId[title.Id] = {
					Label = label,
					Title = title,
					Rarity = rarity,
					Stroke = stroke,
					Exclusive = title.Exclusive == true,
				}
			end
		end
	end

	local currentEquippedId: string? = nil
	local equippedPulseTween: Tween? = nil
	local equippedRainbowConn: RBXScriptConnection? = nil

	local function clearEquippedEffect()
		if equippedPulseTween then
			equippedPulseTween:Cancel()
			equippedPulseTween = nil
		end
		if equippedRainbowConn then
			equippedRainbowConn:Disconnect()
			equippedRainbowConn = nil
		end
	end

	-- Exclusive titles (VIP, etc.) are shown so they can be equipped once granted,
	-- but they don't count toward the Index completion percentage — they were
	-- never rollable in the first place.
	function IndexPanel.Refresh(newState)
		local discovered = 0
		local total = 0
		for titleId, info in entryByTitleId do
			local isDiscovered = newState.DiscoveredTitles[titleId] == true
			if not info.Exclusive then
				total += 1
				if isDiscovered then
					discovered += 1
				end
			end

			if isDiscovered then
				info.Label.Text = info.Title.Name
				info.Label.TextColor3 = info.Rarity.Color
			elseif info.Exclusive then
				info.Label.Text = "VIP Only"
				info.Label.TextColor3 = Theme.Accent
			else
				info.Label.Text = "???"
				info.Label.TextColor3 = Theme.SubText
			end

			-- The currently-equipped entry's stroke is fully owned by the
			-- equip-effect block below; leave it alone here.
			if titleId ~= newState.EquippedTitle then
				info.Stroke.Color = info.Rarity.Color
				info.Stroke.Thickness = 2
				info.Stroke.Transparency = isDiscovered and 0.55 or 0.92
			end
		end

		if newState.EquippedTitle ~= currentEquippedId then
			clearEquippedEffect()
			currentEquippedId = newState.EquippedTitle
			local info = currentEquippedId and entryByTitleId[currentEquippedId]
			if info then
				info.Stroke.Thickness = 3
				info.Stroke.Transparency = 0
				if info.Rarity.Name == "Secret" then
					equippedRainbowConn = RunService.Heartbeat:Connect(function()
						info.Stroke.Color = Color3.fromHSV((tick() * 0.2) % 1, 0.8, 1)
					end)
				else
					info.Stroke.Color = info.Rarity.Color
					equippedPulseTween = TweenService:Create(
						info.Stroke,
						TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
						{ Transparency = 0.45 }
					)
					equippedPulseTween:Play()
				end
			end
		end

		local percent = total > 0 and math.floor((discovered / total) * 100) or 0
		header.Text = `Title Index — {percent}% ({discovered}/{total})`
	end

	return frame
end

return IndexPanel
