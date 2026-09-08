--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIFactory = require(ReplicatedStorage.Shared.UIFactory)
local Config = require(ReplicatedStorage.Shared.Config)

local RebirthPanel = {}
local Theme = UIFactory.Theme

function RebirthPanel.Create(parent: Instance, state, RemoteController, notification)
	local frame = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	local card = UIFactory.Card({
		Size = UDim2.new(0, 480, 0, 320),
		Position = UDim2.new(0.5, -240, 0, 20),
		Parent = frame,
	})
	UIFactory.UpgradeCardGlow(card, Theme.Violet, 1.5)
	UIFactory.Padding(24).Parent = card

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 14)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = card

	UIFactory.Title({
		Text = "✦ Rebirth",
		TextSize = 30,
		TextColor3 = Theme.Violet,
		Size = UDim2.new(1, 0, 0, 40),
		LayoutOrder = 1,
		Parent = card,
	})

	UIFactory.Label({
		Text = "Reset your coins for a permanent boost to coin gain and luck.",
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 36),
		LayoutOrder = 2,
		Parent = card,
	})

	local statsLabel = UIFactory.Label({
		Text = "",
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 60),
		LayoutOrder = 3,
		Parent = card,
	})

	local rebirthButton = UIFactory.Button({
		Text = "Rebirth — Requires 0 🪙",
		TextSize = 22,
		Size = UDim2.new(1, 0, 0, 64),
		LayoutOrder = 4,
		Parent = card,
	})

	rebirthButton.MouseButton1Click:Connect(function()
		local result = RemoteController.Rebirth()
		if result.Success then
			notification.Show(`Rebirthed! You are now Rebirth {result.Rebirths}.`, "Success")
		else
			notification.Show(`You need {result.Requirement} coins to rebirth.`, "Danger")
		end
	end)

	function RebirthPanel.Refresh(newState)
		rebirthButton.Text = `Rebirth — Requires {newState.RebirthRequirement} 🪙`

		local coinBonus = newState.Rebirths * Config.RebirthCoinBonusPerRebirth * 100
		local luckBonus = newState.Rebirths * Config.RebirthLuckBonusPerRebirth * 100
		local nextCoinBonus = coinBonus + (Config.RebirthCoinBonusPerRebirth * 100)
		local nextLuckBonus = luckBonus + (Config.RebirthLuckBonusPerRebirth * 100)

		statsLabel.Text = string.format(
			"Current: +%d%% coins, +%d%% luck\nNext rebirth: +%d%% coins, +%d%% luck",
			coinBonus,
			luckBonus,
			nextCoinBonus,
			nextLuckBonus
		)
	end

	return frame
end

return RebirthPanel
