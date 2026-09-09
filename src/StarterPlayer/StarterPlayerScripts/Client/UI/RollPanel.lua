--!strict
-- The main screen: big Roll button, pity progress, result reveal, Auto-Roll toggle.
-- The reveal card's border color/glow reacts to the rolled rarity, topped off
-- with an expanding "burst ring", a little paw/heart confetti pop for Epic+,
-- and — for the rarest pulls — a cycling rainbow border, so the moment of the
-- roll is the visual high point of the UI.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local UIFactory = require(ReplicatedStorage.Shared.UIFactory)
local Effects = require(ReplicatedStorage.Shared.Effects)
local Titles = require(ReplicatedStorage.Shared.Titles)
local Config = require(ReplicatedStorage.Shared.Config)

local RollPanel = {}
local Theme = UIFactory.Theme

local EPIC_MIN_INDEX = Config.PityMinRarityIndex
local CONFETTI_GLYPHS = { "🐾", "💕", "⭐", "✨" }
local RESULT_CENTER = UDim2.new(0.5, 0, 0, 90)

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

	local resultCard = UIFactory.Card({
		Size = UDim2.new(0, 420, 0, 140),
		Position = UDim2.new(0.5, -210, 0, 20),
		Parent = frame,
	})
	local resultStroke = resultCard:FindFirstChildOfClass("UIStroke") :: UIStroke
	resultStroke.Thickness = 2

	local resultTitle = UIFactory.Title({
		Text = "🐱 Roll to reveal your Pusheen!",
		TextSize = 24,
		Size = UDim2.new(1, -20, 0, 50),
		Position = UDim2.new(0, 10, 0, 20),
		Parent = resultCard,
	})

	local resultRarity = UIFactory.Label({
		Text = "",
		Font = Theme.FontMedium,
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
		Text = `🎲 ROLL — {Config.BaseRollCost} 🪙`,
		TextSize = 26,
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

	local autoRollToggle, setAutoRollActive = UIFactory.NavButton({
		Text = "Enable Auto-Roll",
		Size = UDim2.new(0, 220, 0, 44),
		Position = UDim2.new(0.5, -110, 0, 360),
		Parent = frame,
	})

	local _hint = UIFactory.Label({
		Text = "🐾 Tip: equip a title from the Index tab to boost your coin gain.",
		TextColor3 = Theme.SubText,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(0, 500, 0, 20),
		Position = UDim2.new(0.5, -250, 0, 415),
		Parent = frame,
	})

	local pulseTween: Tween? = nil
	local rainbowConn: RBXScriptConnection? = nil

	local function clearRevealEffect()
		if pulseTween then
			pulseTween:Cancel()
			pulseTween = nil
		end
		if rainbowConn then
			rainbowConn:Disconnect()
			rainbowConn = nil
		end
	end

	function RollPanel.PlayRollResult(result)
		local rarity = result.Rarity
		resultTitle.Text = result.Title.Name
		resultTitle.TextColor3 = rarity.Color
		resultRarity.Text = rarity.Name .. (result.PityTriggered and " (Pity!)" or "")
		resultRarity.TextColor3 = rarity.Color
		newBadge.Visible = result.IsNew

		clearRevealEffect()
		local isEpicPlus = rarity.Index >= EPIC_MIN_INDEX
		if rarity.Name == "Secret" then
			resultStroke.Thickness = 3
			resultStroke.Transparency = 0
			rainbowConn = RunService.Heartbeat:Connect(function()
				resultStroke.Color = Color3.fromHSV((tick() * 0.2) % 1, 0.8, 1)
			end)
		else
			resultStroke.Color = rarity.Color
			resultStroke.Thickness = isEpicPlus and 3 or 2
			resultStroke.Transparency = 0.2
			if isEpicPlus then
				pulseTween = TweenService:Create(
					resultStroke,
					TweenInfo.new(0.75, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
					{ Transparency = 0.75 }
				)
				pulseTween:Play()
			end
		end

		Effects.SpawnBurstRing(frame, RESULT_CENTER, rarity.Color, isEpicPlus)
		if isEpicPlus then
			Effects.SpawnBurstRing(frame, RESULT_CENTER, rarity.Color, false)
			Effects.SpawnConfetti(frame, RESULT_CENTER, CONFETTI_GLYPHS, rarity.Name == "Secret" and 16 or 10)
		end

		if result.SetBonusGranted then
			notification.Show(`Full {rarity.Name} collection bonus unlocked! +Luck`, "Success")
		end
	end

	rollButton.MouseButton1Click:Connect(function()
		local result = RemoteController.RollTitle()
		if not result.Success then
			if result.Reason == "NotEnoughCoins" then
				notification.Show(`You need {result.Cost} coins to roll — {Config.BaseIdleCoinsPerSecond}/sec is coming in passively!`, "Danger")
			elseif result.Reason == "NetworkError" then
				notification.Show("Couldn't reach the server — try again in a moment.", "Danger")
			else
				notification.Show("Couldn't roll right now — try again.", "Danger")
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
		rollButton.Text = `🎲 ROLL — {newState.RollCost} 🪙`
		pityLabel.Text = `Pity: {newState.RollsSincePity} / {Config.PityRollThreshold}`
		setPityFraction(newState.RollsSincePity / Config.PityRollThreshold)
		autoRollToggle.Text = newState.AutoRollEnabled and "Auto-Roll: ON" or "Enable Auto-Roll"
		setAutoRollActive(newState.AutoRollEnabled)

		local title = newState.EquippedTitle and titleById[newState.EquippedTitle]
		equippedLabel.Text = title and ("Equipped: " .. title.Name) or "Equipped: None"
	end

	return frame
end

return RollPanel
