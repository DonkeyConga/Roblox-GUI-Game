--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIFactory = require(ReplicatedStorage.Shared.UIFactory)
local Config = require(ReplicatedStorage.Shared.Config)

local ShopPanel = {}
local Theme = UIFactory.Theme

function ShopPanel.Create(parent: Instance, state, RemoteController, notification)
	local frame = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = parent,
	})

	local card = UIFactory.Card({
		Size = UDim2.new(0, 420, 0, 340),
		Position = UDim2.new(0.5, -210, 0, 20),
		Parent = frame,
	})
	UIFactory.UpgradeCardGlow(card, Theme.Accent, 1.5)
	UIFactory.Padding(24).Parent = card

	-- A little rotated ribbon banner in the corner, gacha-shop style.
	local ribbon = UIFactory.Label({
		Text = "★ VIP ★",
		Font = Theme.FontDisplay,
		TextSize = 14,
		TextColor3 = Theme.TextOnGold,
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -28, 0, 28),
		Size = UDim2.new(0, 110, 0, 26),
		Rotation = 35,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 5,
		Parent = card,
	})
	UIFactory.Corner(4).Parent = ribbon

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = card

	UIFactory.Title({
		Text = "⭐ VIP",
		TextSize = 26,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 34),
		LayoutOrder = 1,
		Parent = card,
	})

	local perks = {
		`{Config.VIPCoinMultiplier}x Coins earned`,
		`{Config.VIPLuckMultiplier}x Luck on every roll`,
		"Unlocks Auto-Roll immediately",
		"Exclusive VIP title",
	}
	for i, perk in perks do
		UIFactory.Label({
			Text = "✓ " .. perk,
			TextColor3 = Theme.SubText,
			Size = UDim2.new(1, 0, 0, 22),
			LayoutOrder = i + 1,
			Parent = card,
		})
	end

	local buyButton = UIFactory.Button({
		Text = "Purchase VIP",
		TextSize = 20,
		Size = UDim2.new(1, 0, 0, 50),
		LayoutOrder = 10,
		Parent = card,
	})

	buyButton.MouseButton1Click:Connect(function()
		if state.OwnsVIP then
			return
		end
		local result = RemoteController.BuyVIP()
		if not result.Success then
			notification.Show("VIP isn't configured yet — check back soon!", "Danger")
		end
	end)

	function ShopPanel.Refresh(newState)
		if newState.OwnsVIP then
			buyButton.Text = "VIP Owned ✓"
			UIFactory.SetButtonState(buyButton, "Owned")
		else
			buyButton.Text = "Purchase VIP"
			UIFactory.SetButtonState(buyButton, "Gold")
		end
	end

	return frame
end

return ShopPanel
