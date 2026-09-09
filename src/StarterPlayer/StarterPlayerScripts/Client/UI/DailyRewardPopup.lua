--!strict
-- Full-screen modal shown once per day on join, prompting the player to claim
-- their login-streak reward. Requires an explicit click (not auto-granted) —
-- that small bit of friction is what makes it feel like a reward, not a tax refund.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIFactory = require(ReplicatedStorage.Shared.UIFactory)

local DailyRewardPopup = {}
local Theme = UIFactory.Theme

function DailyRewardPopup.Create(screenGui: ScreenGui, RemoteController, notification)
	local overlay = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 1,
		Visible = false,
		ZIndex = 50,
		Parent = screenGui,
	})

	local card = UIFactory.Card({
		Size = UDim2.new(0, 360, 0, 260),
		Position = UDim2.new(0.5, -180, 0.5, -130),
		ZIndex = 51,
		Parent = overlay,
	})
	UIFactory.UpgradeCardGlow(card, Theme.Accent, 2)

	local cardScale = Instance.new("UIScale")
	cardScale.Parent = card

	UIFactory.Title({
		Text = "🎁 Daily Pusheen Reward!",
		TextSize = 26,
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 20),
		ZIndex = 51,
		Parent = card,
	})

	local dayLabel = UIFactory.Label({
		Text = "Day 1",
		TextColor3 = Theme.SubText,
		Font = Theme.FontMedium,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 0, 70),
		ZIndex = 51,
		Parent = card,
	})

	local rewardLabel = UIFactory.Title({
		Text = "🐟 100",
		TextSize = 40,
		TextColor3 = Theme.Accent,
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.new(0, 0, 0, 110),
		ZIndex = 51,
		Parent = card,
	})

	local claimButton = UIFactory.Button({
		Text = "Claim",
		TextSize = 20,
		Size = UDim2.new(0, 200, 0, 50),
		Position = UDim2.new(0.5, -100, 0, 190),
		ZIndex = 51,
		Parent = card,
	})

	claimButton.MouseButton1Click:Connect(function()
		local result = RemoteController.ClaimDailyStreak()
		if result.Success then
			TweenService:Create(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			task.delay(0.2, function()
				overlay.Visible = false
			end)
		elseif result.Reason == "AlreadyClaimed" then
			overlay.Visible = false
		elseif notification then
			notification.Show("Couldn't claim your reward right now — try again.", "Danger")
		end
	end)

	local api = {}
	function api.Show(info)
		dayLabel.Text = `Day {info.Day} Streak`
		rewardLabel.Text = `🐟 {info.Reward}`

		overlay.Visible = true
		overlay.BackgroundTransparency = 1
		cardScale.Scale = 0.7

		TweenService:Create(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.5 }):Play()
		TweenService:Create(
			cardScale,
			TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	end

	return api
end

return DailyRewardPopup
