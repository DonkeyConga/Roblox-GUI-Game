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

	local card = UIFactory.Frame({
		Size = UDim2.new(0, 420, 0, 320),
		Position = UDim2.new(0.5, -210, 0, 20),
		Parent = frame,
	})
	UIFactory.Corner(16).Parent = card
	UIFactory.Padding(20).Parent = card

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.Parent = card

	UIFactory.Label({
		Text = "⭐ VIP",
		Font = Theme.Font,
		TextSize = 26,
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
		Font = Theme.Font,
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
			buyButton.Active = false
			buyButton.BackgroundColor3 = Theme.Success
		else
			buyButton.Text = "Purchase VIP"
			buyButton.Active = true
			buyButton.BackgroundColor3 = Theme.Accent
		end
	end

	return frame
end

return ShopPanel
