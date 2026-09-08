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

	UIFactory.Label({
		Text = "Rebirth",
		Font = Theme.Font,
		TextSize = 26,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 40),
		Parent = frame,
	})

	UIFactory.Label({
		Text = "Reset your coins for a permanent boost to coin gain and luck.",
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextWrapped = true,
		Size = UDim2.new(0, 500, 0, 40),
		Position = UDim2.new(0.5, -250, 0, 46),
		Parent = frame,
	})

	local statsLabel = UIFactory.Label({
		Text = "",
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextWrapped = true,
		Size = UDim2.new(0, 500, 0, 80),
		Position = UDim2.new(0.5, -250, 0, 96),
		Parent = frame,
	})

	local rebirthButton = UIFactory.Button({
		Text = "Rebirth — Requires 0 🪙",
		Font = Theme.Font,
		TextSize = 24,
		Size = UDim2.new(0, 280, 0, 64),
		Position = UDim2.new(0.5, -140, 0, 190),
		Parent = frame,
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
