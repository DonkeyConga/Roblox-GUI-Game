--!strict
-- Collection log: every title grouped by rarity, "???" until discovered.
-- Tap a discovered title to equip it (tap again to unequip). state is the
-- same mutable table MainUI feeds from DataSync, so click handlers can read
-- current discovery/equip status live without waiting for a fresh Refresh.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

	local header = UIFactory.Label({
		Text = "Title Index — 0%",
		Font = Theme.Font,
		TextSize = 22,
		Size = UDim2.new(1, 0, 0, 30),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = frame,
	})

	UIFactory.Label({
		Text = "Tap a discovered title to equip it. Tap again to unequip.",
		TextColor3 = Theme.SubText,
		TextSize = 13,
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, 0, 0, 30),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = frame,
	})

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, -54)
	scroll.Position = UDim2.new(0, 0, 0, 54)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = frame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 12)
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
			Size = UDim2.new(1, 0, 0, 26),
			Parent = section,
		})

		local grid = UIFactory.Frame({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
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
				stroke.Transparency = 1
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
			info.Stroke.Transparency = (newState.EquippedTitle == titleId) and 0 or 1
		end
		local percent = total > 0 and math.floor((discovered / total) * 100) or 0
		header.Text = `Title Index — {percent}% ({discovered}/{total})`
	end

	return frame
end

return IndexPanel
