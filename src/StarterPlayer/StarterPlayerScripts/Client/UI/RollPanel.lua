--!strict
-- The main screen: big Roll button, pity progress, result reveal, Auto-Roll toggle.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UIFactory = require(ReplicatedStorage.Shared.UIFactory)
local Titles = require(ReplicatedStorage.Shared.Titles)
local Config = require(ReplicatedStorage.Shared.Config)

local RollPanel = {}
local Theme = UIFactory.Theme

local titleById = {}
for _, title in Titles do
	titleById[title.Id] = title
end

function RollPanel.Create(parent: Instance, state, RemoteController, notification)
	local frame = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	local resultCard = UIFactory.Frame({
		Size = UDim2.new(0, 420, 0, 140),
		Position = UDim2.new(0.5, -210, 0, 20),
		Parent = frame,
	})
	UIFactory.Corner(16).Parent = resultCard

	local resultTitle = UIFactory.Label({
		Text = "Roll to reveal your title!",
		Font = Theme.Font,
		TextSize = 26,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -20, 0, 50),
		Position = UDim2.new(0, 10, 0, 20),
		Parent = resultCard,
	})

	local resultRarity = UIFactory.Label({
		Text = "",
		Font = Theme.FontRegular,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 0, 75),
		Parent = resultCard,
	})

	local newBadge = UIFactory.Label({
		Text = "NEW!",
		Font = Theme.Font,
		TextSize = 16,
		TextColor3 = Theme.Success,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, -20, 0, 20),
		Position = UDim2.new(0, 10, 0, 108),
		Visible = false,
		Parent = resultCard,
	})

	local pityLabel = UIFactory.Label({
		Text = `Pity: 0 / {Config.PityRollThreshold}`,
		TextColor3 = Theme.SubText,
		Size = UDim2.new(0, 300, 0, 24),
		Position = UDim2.new(0.5, -150, 0, 175),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = frame,
	})

	local pityBarContainer = UIFactory.Frame({
		Size = UDim2.new(0, 300, 0, 10),
		Position = UDim2.new(0.5, -150, 0, 202),
		BackgroundTransparency = 1,
		Parent = frame,
	})
	local _, setPityFraction = UIFactory.ProgressBar(pityBarContainer, 0)

	local rollButton = UIFactory.Button({
		Text = `ROLL — {Config.BaseRollCost} 🪙`,
		Font = Theme.Font,
		TextSize = 28,
		Size = UDim2.new(0, 280, 0, 70),
		Position = UDim2.new(0.5, -140, 0, 230),
		Parent = frame,
	})

	local equippedLabel = UIFactory.Label({
		Text = "Equipped: None",
		TextColor3 = Theme.SubText,
		Size = UDim2.new(0, 400, 0, 24),
		Position = UDim2.new(0.5, -200, 0, 320),
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = frame,
	})

	local autoRollToggle = UIFactory.Button({
		Text = "Enable Auto-Roll",
		Size = UDim2.new(0, 220, 0, 44),
		Position = UDim2.new(0.5, -110, 0, 360),
		BackgroundColor3 = Theme.PanelLight,
		Parent = frame,
	})

	local _hint = UIFactory.Label({
		Text = "Tip: equip a title from the Index tab to boost your coin gain.",
		TextColor3 = Theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(0, 500, 0, 20),
		Position = UDim2.new(0.5, -250, 0, 415),
		Parent = frame,
	})

	function RollPanel.PlayRollResult(result)
		local rarity = result.Rarity
		resultTitle.Text = result.Title.Name
		resultTitle.TextColor3 = rarity.Color
		resultRarity.Text = rarity.Name .. (result.PityTriggered and " (Pity!)" or "")
		resultRarity.TextColor3 = rarity.Color
		newBadge.Visible = result.IsNew

		resultCard.BackgroundColor3 = Theme.Panel
		local flashIn = TweenService:Create(resultCard, TweenInfo.new(0.15), { BackgroundColor3 = rarity.Color })
		flashIn.Completed:Connect(function()
			TweenService:Create(resultCard, TweenInfo.new(0.4), { BackgroundColor3 = Theme.Panel }):Play()
		end)
		flashIn:Play()

		if result.SetBonusGranted then
			notification.Show(`Full {rarity.Name} collection bonus unlocked! +Luck`, "Success")
		end
	end

	rollButton.MouseButton1Click:Connect(function()
		local result = RemoteController.RollTitle()
		if not result.Success then
			if result.Reason == "NotEnoughCoins" then
				notification.Show(`You need {result.Cost} coins to roll.`, "Danger")
			end
			return
		end
		RollPanel.PlayRollResult(result)
	end)

	autoRollToggle.MouseButton1Click:Connect(function()
		if not state.CanAutoRoll then
			notification.Show(`Unlock Auto-Roll with VIP or Rebirth {Config.AutoRollUnlockRebirths}+.`, "Danger")
			return
		end
		local result = RemoteController.ToggleAutoRoll(not state.AutoRollEnabled)
		if not result.Success then
			notification.Show("Auto-Roll is locked.", "Danger")
		end
	end)

	function RollPanel.Refresh(newState)
		rollButton.Text = `ROLL — {newState.RollCost} 🪙`
		pityLabel.Text = `Pity: {newState.RollsSincePity} / {Config.PityRollThreshold}`
		setPityFraction(newState.RollsSincePity / Config.PityRollThreshold)
		autoRollToggle.Text = newState.AutoRollEnabled and "Disable Auto-Roll" or "Enable Auto-Roll"
		autoRollToggle.BackgroundColor3 = newState.AutoRollEnabled and Theme.Success or Theme.PanelLight

		local title = newState.EquippedTitle and titleById[newState.EquippedTitle]
		equippedLabel.Text = title and ("Equipped: " .. title.Name) or "Equipped: None"
	end

	return frame
end

return RollPanel
