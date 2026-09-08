--!strict
-- Full-screen modal shown once per day on join, prompting the player to claim
-- their login-streak reward. Requires an explicit click (not auto-granted) —
-- that small bit of friction is what makes it feel like a reward, not a tax refund.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIFactory = require(ReplicatedStorage.Shared.UIFactory)

local DailyRewardPopup = {}
local Theme = UIFactory.Theme

function DailyRewardPopup.Create(screenGui: ScreenGui, RemoteController)
	local overlay = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.5,
		Visible = false,
		ZIndex = 50,
		Parent = screenGui,
	})

	local card = UIFactory.Frame({
		Size = UDim2.new(0, 360, 0, 260),
		Position = UDim2.new(0.5, -180, 0.5, -130),
		ZIndex = 51,
		Parent = overlay,
	})
	UIFactory.Corner(16).Parent = card

	UIFactory.Label({
		Text = "Daily Reward!",
		Font = Theme.Font,
		TextSize = 26,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 40),
		Position = UDim2.new(0, 0, 0, 20),
		ZIndex = 51,
		Parent = card,
	})

	local dayLabel = UIFactory.Label({
		Text = "Day 1",
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 0, 70),
		ZIndex = 51,
		Parent = card,
	})

	local rewardLabel = UIFactory.Label({
		Text = "🪙 100",
		Font = Theme.Font,
		TextSize = 36,
		TextColor3 = Color3.fromRGB(255, 210, 60),
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 60),
		Position = UDim2.new(0, 0, 0, 110),
		ZIndex = 51,
		Parent = card,
	})

	local claimButton = UIFactory.Button({
		Text = "Claim",
		Font = Theme.Font,
		TextSize = 20,
		Size = UDim2.new(0, 200, 0, 50),
		Position = UDim2.new(0.5, -100, 0, 190),
		ZIndex = 51,
		Parent = card,
	})

	claimButton.MouseButton1Click:Connect(function()
		local result = RemoteController.ClaimDailyStreak()
		if result.Success then
			overlay.Visible = false
		end
	end)

	local api = {}
	function api.Show(info)
		dayLabel.Text = `Day {info.Day} Streak`
		rewardLabel.Text = `🪙 {info.Reward}`
		overlay.Visible = true
	end

	return api
end

return DailyRewardPopup
