--!strict
-- Small reusable animation helpers shared across panels: expanding burst
-- rings, emoji confetti bursts, a tweened number count-up, and a panel
-- pop-in. Kept separate from UIFactory (which builds static-looking
-- components) so "things that move over time" live in one place.
local TweenService = game:GetService("TweenService")

local Effects = {}

-- A ring that blooms outward from `position` (relative to `parent`) and
-- fades — used for the roll-result reveal. Bigger + longer-lived for `big` rolls.
function Effects.SpawnBurstRing(parent: GuiObject, position: UDim2, color: Color3, big: boolean)
	local ring = Instance.new("Frame")
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.Position = position
	ring.Size = UDim2.new(0, 40, 0, 40)
	ring.BackgroundColor3 = color
	ring.BackgroundTransparency = 0.15
	ring.BorderSizePixel = 0
	ring.ZIndex = math.max(parent.ZIndex - 1, 0)
	ring.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.5, 0)
	corner.Parent = ring

	local targetSize = big and 620 or 400
	TweenService:Create(
		ring,
		TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Size = UDim2.new(0, targetSize, 0, targetSize), BackgroundTransparency = 1 }
	):Play()
	task.delay(0.65, function()
		ring:Destroy()
	end)
end

-- A little burst of emoji "confetti" flying outward from `position` and
-- fading — used for high-rarity roll reveals. `glyphs` is a list of emoji
-- strings picked from at random (e.g. paws, hearts, stars).
function Effects.SpawnConfetti(parent: GuiObject, position: UDim2, glyphs: { string }, count: number?)
	local total = count or 8
	for i = 1, total do
		local glyph = glyphs[math.random(1, #glyphs)]
		local label = Instance.new("TextLabel")
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Position = position
		label.Size = UDim2.new(0, 28, 0, 28)
		label.BackgroundTransparency = 1
		label.Text = glyph
		label.TextSize = 22
		label.Rotation = math.random(-30, 30)
		label.ZIndex = (parent.ZIndex or 1) + 5
		label.Parent = parent

		local angle = (i / total) * math.pi * 2 + math.random() * 0.5
		local distance = math.random(90, 170)
		local offsetX = math.cos(angle) * distance
		local offsetY = math.sin(angle) * distance - 40 -- bias upward, like a little pop

		TweenService:Create(
			label,
			TweenInfo.new(0.7 + math.random() * 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(
					position.X.Scale,
					position.X.Offset + offsetX,
					position.Y.Scale,
					position.Y.Offset + offsetY
				),
				TextTransparency = 1,
				Rotation = label.Rotation + math.random(-90, 90),
			}
		):Play()

		task.delay(1.1, function()
			label:Destroy()
		end)
	end
end

-- Compact display formatting shared by the top bar and the leaderboard
-- (e.g. 12500 -> "12.50K") so both always agree on how big numbers read.
function Effects.FormatNumber(n: number): string
	n = math.floor(n)
	if n >= 1e12 then
		return string.format("%.2fT", n / 1e12)
	elseif n >= 1e9 then
		return string.format("%.2fB", n / 1e9)
	elseif n >= 1e6 then
		return string.format("%.2fM", n / 1e6)
	elseif n >= 1e3 then
		return string.format("%.2fK", n / 1e3)
	end
	return tostring(n)
end

-- Tweens a number displayed in `label` from its current value to `toValue`
-- over `duration` seconds, calling `format` to turn each intermediate number
-- into display text. Used for the top-bar treats/rebirths counters so changes
-- feel alive instead of snapping.
function Effects.CountUpNumber(
	label: TextLabel,
	fromValue: number,
	toValue: number,
	format: (number) -> string,
	duration: number?
)
	if math.abs(toValue - fromValue) < 0.5 then
		label.Text = format(toValue)
		return
	end
	local holder = Instance.new("NumberValue")
	holder.Value = fromValue

	local connection
	connection = holder:GetPropertyChangedSignal("Value"):Connect(function()
		label.Text = format(holder.Value)
	end)

	local tween = TweenService:Create(
		holder,
		TweenInfo.new(duration or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Value = toValue }
	)
	tween.Completed:Connect(function()
		label.Text = format(toValue)
		connection:Disconnect()
		holder:Destroy()
	end)
	tween:Play()
end

-- A quick, appealing pop-in for a panel becoming visible: scales up from
-- slightly-small with a little overshoot. Call right after Visible = true.
function Effects.PopIn(frame: GuiObject)
	local scale = frame:FindFirstChildOfClass("UIScale")
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = frame
	end
	scale.Scale = 0.94
	TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

-- A gentle, endless up-down bob — used for a small cute icon (e.g. a paw)
-- that should feel alive even when nothing else is happening.
function Effects.Bob(instance: GuiObject, amplitudePixels: number?, duration: number?)
	local amplitude = amplitudePixels or 4
	local baseY = instance.Position.Y
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(duration or 1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Position = UDim2.new(instance.Position.X.Scale, instance.Position.X.Offset, baseY.Scale, baseY.Offset - amplitude) }
	)
	tween:Play()
	return tween
end

return Effects
