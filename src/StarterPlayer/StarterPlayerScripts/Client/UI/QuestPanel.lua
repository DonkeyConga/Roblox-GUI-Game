--!strict
-- Daily quests (with progress bars + claim buttons) followed by the permanent
-- achievements list (auto-granted server-side, shown here just as a checklist).
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIFactory = require(ReplicatedStorage.Shared.UIFactory)

local QuestPanel = {}
local Theme = UIFactory.Theme

local function createQuestEntry(parent: Instance, layoutOrder: number)
	local entry = UIFactory.Card({
		Size = UDim2.new(1, 0, 0, 80),
		LayoutOrder = layoutOrder,
		Parent = parent,
	})
	UIFactory.Padding(10).Parent = entry

	local desc = UIFactory.Label({
		Text = "",
		Font = Theme.Font,
		TextSize = 16,
		Size = UDim2.new(1, -100, 0, 20),
		Parent = entry,
	})

	local barContainer = UIFactory.Frame({
		Size = UDim2.new(1, -100, 0, 10),
		Position = UDim2.new(0, 0, 0, 30),
		BackgroundTransparency = 1,
		Parent = entry,
	})
	local _, setFraction = UIFactory.ProgressBar(barContainer, 0)

	local progressLabel = UIFactory.Label({
		Text = "",
		TextColor3 = Theme.SubText,
		TextSize = 13,
		Size = UDim2.new(1, -100, 0, 16),
		Position = UDim2.new(0, 0, 0, 46),
		Parent = entry,
	})

	local claimButton = UIFactory.Button({
		Text = "Claim",
		Size = UDim2.new(0, 80, 0, 60),
		Position = UDim2.new(1, -80, 0, 10),
		Parent = entry,
	})

	return { Entry = entry, Desc = desc, SetFraction = setFraction, ProgressLabel = progressLabel, ClaimButton = claimButton }
end

function QuestPanel.Create(parent: Instance, state, RemoteController, notification)
	local frame = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, 0)
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

	UIFactory.Title({
		Text = "📜 Daily Pusheen Quests",
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 0,
		Size = UDim2.new(1, 0, 0, 28),
		Parent = scroll,
	})

	UIFactory.Title({
		Text = "🏆 Achievements",
		TextSize = 20,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 100,
		Size = UDim2.new(1, 0, 0, 28),
		Parent = scroll,
	})

	local questEntries = {}
	local achievementEntries = {}

	function QuestPanel.Refresh(newState)
		for i, questInfo in newState.Quests or {} do
			local entryData = questEntries[questInfo.Id]
			if not entryData then
				entryData = createQuestEntry(scroll, i)
				entryData.ClaimButton.MouseButton1Click:Connect(function()
					local result = RemoteController.ClaimQuest(questInfo.Id)
					if result.Success then
						notification.Show(`🐾 Claimed {result.Reward} coins!`, "Success")
					elseif result.Reason == "NotComplete" then
						notification.Show("Not finished yet — keep going!", "Danger")
					elseif result.Reason == "AlreadyClaimed" then
						notification.Show("Already claimed today.", "Danger")
					elseif result.Reason == "NetworkError" then
						notification.Show("Couldn't reach the server — try again in a moment.", "Danger")
					else
						notification.Show("Couldn't claim that quest right now.", "Danger")
					end
				end)
				questEntries[questInfo.Id] = entryData
			end
			entryData.Entry.LayoutOrder = i

			entryData.Desc.Text = questInfo.Description
			entryData.ProgressLabel.Text = `{questInfo.Progress} / {questInfo.Target}  •  Reward: {questInfo.Reward} 🪙`
			entryData.SetFraction(questInfo.Progress / questInfo.Target)

			if questInfo.Claimed then
				entryData.ClaimButton.Text = "Claimed"
				UIFactory.SetButtonState(entryData.ClaimButton, "Disabled")
			elseif questInfo.Progress >= questInfo.Target then
				entryData.ClaimButton.Text = "Claim"
				UIFactory.SetButtonState(entryData.ClaimButton, "Success")
			else
				entryData.ClaimButton.Text = "..."
				UIFactory.SetButtonState(entryData.ClaimButton, "Disabled")
			end
		end

		for i, achievementInfo in newState.Achievements or {} do
			local rowData = achievementEntries[achievementInfo.Id]
			if not rowData then
				local row = UIFactory.Frame({
					Size = UDim2.new(1, 0, 0, 36),
					LayoutOrder = 100 + i,
					Parent = scroll,
				})
				UIFactory.Corner(8).Parent = row

				local label = UIFactory.Label({
					Text = "",
					Size = UDim2.new(1, -90, 1, 0),
					Position = UDim2.new(0, 10, 0, 0),
					Parent = row,
				})
				local rewardLabel = UIFactory.Label({
					Text = "",
					TextColor3 = Theme.Accent,
					Font = Theme.FontMedium,
					TextXAlignment = Enum.TextXAlignment.Right,
					Size = UDim2.new(0, 70, 1, 0),
					Position = UDim2.new(1, -80, 0, 0),
					Parent = row,
				})
				rowData = { Row = row, Label = label, RewardLabel = rewardLabel }
				achievementEntries[achievementInfo.Id] = rowData
			end
			rowData.Row.LayoutOrder = 100 + i

			rowData.Label.Text = (achievementInfo.Completed and "✓ " or "• ") .. achievementInfo.Description
			rowData.Label.TextColor3 = achievementInfo.Completed and Theme.Success or Theme.SubText
			rowData.RewardLabel.Text = tostring(achievementInfo.Reward) .. " 🪙"
			rowData.RewardLabel.TextColor3 = achievementInfo.Completed and Theme.Accent or Theme.SubText
			rowData.Row.BackgroundColor3 = achievementInfo.Completed and Theme.PanelLight or Theme.Panel
		end
	end

	return frame
end

return QuestPanel
