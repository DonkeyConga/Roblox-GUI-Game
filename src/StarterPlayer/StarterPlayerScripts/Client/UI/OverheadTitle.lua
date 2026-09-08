--!strict
-- Shows every player's equipped title as a BillboardGui above their head.
-- Reads EquippedTitleName/EquippedTitleColor attributes, which the server
-- sets on the Player instance (and which replicate to all clients for free).
local OverheadTitle = {}

local function attach(player: Player, character: Model)
	local head = character:WaitForChild("Head", 5)
	if not head then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "TitleBillboard"
	billboard.Size = UDim2.new(0, 200, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 1, 0)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextStrokeTransparency = 0.5
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Text = ""
	label.Parent = billboard

	local function updateFromAttributes()
		local name = player:GetAttribute("EquippedTitleName")
		local color = player:GetAttribute("EquippedTitleColor")
		label.Text = name or ""
		label.TextColor3 = color or Color3.new(1, 1, 1)
		billboard.Enabled = name ~= nil
	end

	player:GetAttributeChangedSignal("EquippedTitleName"):Connect(updateFromAttributes)
	player:GetAttributeChangedSignal("EquippedTitleColor"):Connect(updateFromAttributes)
	updateFromAttributes()
end

function OverheadTitle.Init(Players: Players)
	local function onPlayerAdded(player: Player)
		player.CharacterAdded:Connect(function(character)
			attach(player, character)
		end)
		if player.Character then
			attach(player, player.Character)
		end
	end

	for _, player in Players:GetPlayers() do
		onPlayerAdded(player)
	end
	Players.PlayerAdded:Connect(onPlayerAdded)
end

return OverheadTitle
