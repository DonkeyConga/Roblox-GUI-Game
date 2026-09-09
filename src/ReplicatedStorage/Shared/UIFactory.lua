--!strict
-- "Pusheen" theme: warm cream/white backdrops, a blush-pink primary accent,
-- a soft lavender secondary (Pusheenicorn-flavored), pastel rarity glows.
-- Every panel builds from these helpers so a single palette/behavior change
-- here reshapes the whole game's look at once. Field NAMES are kept stable
-- across theme changes (Accent, AccentDark, Violet, TextOnGold, etc.) even
-- though what they mean has shifted — that's what lets every panel file
-- stay untouched while the whole game reskins from just this table.
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local UIFactory = {}

UIFactory.Theme = {
	Background = Color3.fromRGB(255, 248, 240),
	BackgroundTop = Color3.fromRGB(255, 232, 236),
	Panel = Color3.fromRGB(255, 255, 255),
	PanelTop = Color3.fromRGB(255, 244, 247),
	PanelLight = Color3.fromRGB(243, 231, 234),
	Accent = Color3.fromRGB(244, 152, 175), -- Pusheen blush pink, the primary CTA color
	AccentDark = Color3.fromRGB(219, 105, 140),
	AccentPale = Color3.fromRGB(255, 214, 226),
	Violet = Color3.fromRGB(178, 154, 224), -- soft lavender, Pusheenicorn-flavored secondary
	Success = Color3.fromRGB(120, 200, 150),
	Danger = Color3.fromRGB(230, 110, 110),
	Text = Color3.fromRGB(60, 45, 50),
	SubText = Color3.fromRGB(115, 95, 100),
	TextOnGold = Color3.fromRGB(110, 40, 60), -- text sitting on the pink accent gradient
	Font = Enum.Font.GothamBlack,
	FontRegular = Enum.Font.Gotham,
	FontMedium = Enum.Font.GothamMedium,
	FontDisplay = Enum.Font.FredokaOne,
}

local Theme = UIFactory.Theme

local function applyProps(instance: Instance, props: { [string]: any }?)
	if not props then
		return
	end
	for key, value in props do
		(instance :: any)[key] = value
	end
end

function UIFactory.Corner(radius: number?): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 12)
	return corner
end

function UIFactory.Padding(all: number?): UIPadding
	local padding = Instance.new("UIPadding")
	local px = UDim.new(0, all or 8)
	padding.PaddingTop = px
	padding.PaddingBottom = px
	padding.PaddingLeft = px
	padding.PaddingRight = px
	return padding
end

function UIFactory.Gradient(colorSequence: ColorSequence, rotation: number?): UIGradient
	local gradient = Instance.new("UIGradient")
	gradient.Color = colorSequence
	gradient.Rotation = rotation or 90
	return gradient
end

-- A stroke that gently and endlessly breathes brighter/dimmer — used to draw
-- the eye to rare rewards and important call-to-actions without being static.
function UIFactory.GlowStroke(instance: Instance, color: Color3, thickness: number?, pulsing: boolean?): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness or 2
	stroke.Transparency = 0.25
	stroke.Parent = instance

	if pulsing then
		local tween = TweenService:Create(
			stroke,
			TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Transparency = 0.75 }
		)
		tween:Play()
	end

	return stroke
end

-- Continuously cycles a stroke's hue for the rarest, most "special" elements
-- (Secret-tier titles). Returns a disconnect function for cleanup.
function UIFactory.RainbowStroke(instance: Instance, thickness: number?): (UIStroke, () -> ())
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = thickness or 2.5
	stroke.Transparency = 0.1
	stroke.Parent = instance

	local connection = RunService.Heartbeat:Connect(function()
		stroke.Color = Color3.fromHSV((tick() * 0.15) % 1, 0.75, 1)
	end)

	local function disconnect()
		connection:Disconnect()
	end

	return stroke, disconnect
end

-- A soft offset shadow dropped behind `instance` (which must already have its
-- final Position/Size/Parent set). Copies `instance`'s corner radius if it
-- has one, so rounded cards get a matching rounded shadow. Purely additive —
-- never call this before the instance is fully placed.
function UIFactory.DropShadow(instance: GuiObject, offset: number?, transparency: number?): Frame
	local shadow = Instance.new("Frame")
	shadow.BackgroundColor3 = Color3.new(0, 0, 0)
	shadow.BackgroundTransparency = transparency or 0.88
	shadow.BorderSizePixel = 0
	shadow.AnchorPoint = instance.AnchorPoint
	shadow.Size = instance.Size
	shadow.Position = instance.Position + UDim2.new(0, offset or 5, 0, offset or 6)
	shadow.ZIndex = math.max(instance.ZIndex - 1, 0)
	shadow.Parent = instance.Parent

	local sourceCorner = instance:FindFirstChildOfClass("UICorner")
	if sourceCorner then
		local shadowCorner = Instance.new("UICorner")
		shadowCorner.CornerRadius = sourceCorner.CornerRadius
		shadowCorner.Parent = shadow
	end

	return shadow
end

-- A Material-style expanding ripple from the click point, clipped to the
-- button's own rounded rect. Attached to every button so clicks always feel
-- tactile. `button.ClipsDescendants` must already be true.
function UIFactory.AttachRipple(button: GuiObject, color: Color3?)
	button.InputBegan:Connect(function(input)
		if
			input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		local absPos = button.AbsolutePosition
		local absSize = button.AbsoluteSize
		if absSize.X <= 0 or absSize.Y <= 0 then
			return
		end

		local ripple = Instance.new("Frame")
		ripple.BackgroundColor3 = color or Color3.new(1, 1, 1)
		ripple.BackgroundTransparency = 0.55
		ripple.BorderSizePixel = 0
		ripple.AnchorPoint = Vector2.new(0.5, 0.5)
		ripple.Position = UDim2.new(0, input.Position.X - absPos.X, 0, input.Position.Y - absPos.Y)
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.ZIndex = button.ZIndex + 2
		ripple.Parent = button

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = ripple

		local targetSize = math.max(absSize.X, absSize.Y) * 1.8
		TweenService:Create(
			ripple,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, targetSize, 0, targetSize), BackgroundTransparency = 1 }
		):Play()
		task.delay(0.55, function()
			ripple:Destroy()
		end)
	end)
end

-- An endless, gentle scale "breathing" pulse — used sparingly (the single
-- most important call-to-action, e.g. the Roll button) to draw the eye
-- without being distracting. Automatically pauses while hovered/pressed by
-- reusing the same UIScale the button's hover/press tweens already drive
-- (starting a new tween on the same property cleanly interrupts this one).
function UIFactory.MakeBreathe(button: GuiObject)
	local scale = button:FindFirstChildOfClass("UIScale")
	if not scale then
		return
	end

	local breatheTween: Tween? = nil
	local function startBreathing()
		breatheTween = TweenService:Create(
			scale,
			TweenInfo.new(1.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Scale = 1.035 }
		)
		breatheTween:Play()
	end

	startBreathing()

	button.MouseEnter:Connect(function()
		if breatheTween then
			breatheTween:Cancel()
		end
	end)
	button.MouseLeave:Connect(function()
		task.delay(0.16, startBreathing)
	end)
end

function UIFactory.Frame(props: { [string]: any }?): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Theme.Panel
	frame.BorderSizePixel = 0
	applyProps(frame, props)
	return frame
end

-- The "hero card" look: soft diagonal gradient + a faint violet hairline
-- border. Used for anything meant to feel premium (result reveal, shop, etc).
function UIFactory.Card(props: { [string]: any }?): Frame
	local card = Instance.new("Frame")
	card.BackgroundColor3 = Theme.Panel
	card.BorderSizePixel = 0
	UIFactory.Corner(16).Parent = card
	UIFactory.Gradient(ColorSequence.new(Theme.PanelTop, Theme.Panel), 90).Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.Violet
	stroke.Thickness = 1
	stroke.Transparency = 0.7
	stroke.Parent = card

	applyProps(card, props)
	UIFactory.DropShadow(card, 5, 0.88)
	return card
end

-- Finds a Card's default hairline stroke and upgrades it into a slow, pulsing
-- glow — used to make a single "hero" card (Rebirth, Shop) feel special.
function UIFactory.UpgradeCardGlow(card: Frame, color: Color3, thickness: number?)
	local stroke = card:FindFirstChildOfClass("UIStroke")
	if not stroke then
		return
	end
	stroke.Color = color
	stroke.Thickness = thickness or 1.5
	stroke.Transparency = 0.5
	TweenService:Create(
		stroke,
		TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ Transparency = 0.85 }
	):Play()
end

function UIFactory.Label(props: { [string]: any }?): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Theme.FontMedium
	label.TextColor3 = Theme.Text
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	-- A very soft white pop-stroke on every label — barely visible on its own,
	-- but it keeps text legible wherever it sits directly on the cream
	-- backdrop instead of a white card.
	label.TextStrokeColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.82
	applyProps(label, props)
	return label
end

-- A bold display headline with a soft white "sticker" halo — for panel
-- titles and the big roll-result reveal text.
function UIFactory.Title(props: { [string]: any }?): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = Theme.FontDisplay
	label.TextColor3 = Theme.Text
	label.TextSize = 28
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Color3.new(1, 1, 1)
	applyProps(label, props)
	return label
end

-- The primary call-to-action button: a blush-pink gradient that brightens
-- and glows on hover. Use SetButtonState to swap it to success/disabled/danger.
function UIFactory.Button(props: { [string]: any }?): TextButton
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	button.BackgroundColor3 = Theme.AccentDark
	button.Font = Theme.Font
	button.TextColor3 = Theme.TextOnGold
	button.TextSize = 16
	button.BorderSizePixel = 0
	UIFactory.Corner(10).Parent = button

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.AccentPale),
		ColorSequenceKeypoint.new(0.55, Theme.Accent),
		ColorSequenceKeypoint.new(1, Theme.AccentDark),
	})
	gradient.Rotation = 90
	gradient.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.AccentPale
	stroke.Thickness = 1.5
	stroke.Transparency = 0.4
	stroke.Parent = button

	-- A diagonal light streak that sweeps across on hover — the classic
	-- "premium button" shine. Scale-based X so it works at any button width.
	local shine = Instance.new("Frame")
	shine.BackgroundColor3 = Color3.new(1, 1, 1)
	shine.BorderSizePixel = 0
	shine.Rotation = 18
	shine.Size = UDim2.new(0, 26, 1, 50)
	shine.Position = UDim2.new(-0.3, 0, 0, -20)
	shine.ZIndex = button.ZIndex + 1
	shine.Parent = button
	UIFactory.Gradient(
		ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
		}),
		0
	).Parent = shine
	local shineGradient = shine:FindFirstChildOfClass("UIGradient") :: UIGradient
	shineGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.55),
		NumberSequenceKeypoint.new(1, 1),
	})

	local scale = Instance.new("UIScale")
	scale.Parent = button

	button.MouseEnter:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.15), { Transparency = 0, Thickness = 2.5 }):Play()
		TweenService:Create(scale, TweenInfo.new(0.15), { Scale = 1.03 }):Play()
		shine.Position = UDim2.new(-0.3, 0, 0, -20)
		TweenService:Create(shine, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1.3, 0, 0, -20),
		}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(stroke, TweenInfo.new(0.15), { Transparency = 0.4, Thickness = 1.5 }):Play()
		TweenService:Create(scale, TweenInfo.new(0.15), { Scale = 1 }):Play()
	end)
	button.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 0.94 }):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 1.03 }):Play()
	end)

	UIFactory.AttachRipple(button, Color3.new(1, 1, 1))

	applyProps(button, props)
	return button
end

-- A quieter secondary button (used for the bottom nav). Returns a setter you
-- call with true/false to flip it between its dim "inactive" look and a
-- glowing gold "active" look — no manual color juggling needed at call sites.
function UIFactory.NavButton(props: { [string]: any }?): (TextButton, (active: boolean) -> ())
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	button.BackgroundColor3 = Theme.Panel
	button.Font = Theme.Font
	button.TextColor3 = Theme.SubText
	button.TextSize = 15
	button.BorderSizePixel = 0
	UIFactory.Corner(10).Parent = button

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.AccentPale),
		ColorSequenceKeypoint.new(0.55, Theme.Accent),
		ColorSequenceKeypoint.new(1, Theme.AccentDark),
	})
	gradient.Rotation = 90
	gradient.Enabled = false
	gradient.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = Theme.Violet
	stroke.Transparency = 0.65
	stroke.Parent = button

	local scale = Instance.new("UIScale")
	scale.Parent = button
	button.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 0.94 }):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 1 }):Play()
	end)

	local function setActive(active: boolean)
		gradient.Enabled = active
		button.TextColor3 = active and Theme.TextOnGold or Theme.SubText
		TweenService:Create(stroke, TweenInfo.new(0.15), {
			Color = active and Theme.AccentPale or Theme.Violet,
			Transparency = active and 0.1 or 0.65,
			Thickness = active and 2 or 1.5,
		}):Play()
		TweenService:Create(button, TweenInfo.new(0.15), {
			BackgroundColor3 = active and Theme.AccentDark or Theme.Panel,
		}):Play()
	end

	UIFactory.AttachRipple(button, Theme.Violet)

	applyProps(button, props)
	return button, setActive
end

-- A minimal, transparent-background button meant to sit directly on top of
-- an external moving highlight (see MainUI's sliding nav pill) — just text,
-- ripple, and a press-scale, no background of its own. Use SetTabActive to
-- flip its text color when the external highlight lands on it.
function UIFactory.TabButton(props: { [string]: any }?): TextButton
	local button = Instance.new("TextButton")
	button.AutoButtonColor = false
	button.ClipsDescendants = true
	button.BackgroundTransparency = 1
	button.Font = Theme.Font
	button.TextColor3 = Theme.SubText
	button.TextSize = 15
	button.BorderSizePixel = 0

	local scale = Instance.new("UIScale")
	scale.Parent = button
	button.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 0.94 }):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 1 }):Play()
	end)

	UIFactory.AttachRipple(button, Theme.Violet)

	applyProps(button, props)
	return button
end

function UIFactory.SetTabActive(button: TextButton, active: boolean)
	TweenService:Create(button, TweenInfo.new(0.15), {
		TextColor3 = active and Theme.TextOnGold or Theme.SubText,
	}):Play()
end

-- Flips a primary Button between its default gold look and a flat state
-- color, disabling the gradient so the flat color reads clearly.
-- "Gold" = default active CTA. "Success" = active green (ready to claim).
-- "Owned" = inactive green (already claimed/purchased, permanently done).
-- "Disabled" = inactive grey (not ready yet). "Danger" = active red.
function UIFactory.SetButtonState(button: TextButton, state: "Gold" | "Success" | "Owned" | "Disabled" | "Danger")
	local gradient = button:FindFirstChildOfClass("UIGradient")
	local stroke = button:FindFirstChildOfClass("UIStroke")

	if state == "Gold" then
		if gradient then
			gradient.Enabled = true
		end
		button.Active = true
		button.BackgroundColor3 = Theme.AccentDark
		button.TextColor3 = Theme.TextOnGold
		if stroke then
			stroke.Color = Theme.AccentPale
			stroke.Transparency = 0.4
		end
	elseif state == "Success" or state == "Owned" then
		if gradient then
			gradient.Enabled = false
		end
		button.Active = (state == "Success")
		button.BackgroundColor3 = Theme.Success
		button.TextColor3 = Color3.new(1, 1, 1)
		if stroke then
			stroke.Color = Color3.fromRGB(210, 255, 225)
			stroke.Transparency = 0.5
		end
	elseif state == "Disabled" then
		if gradient then
			gradient.Enabled = false
		end
		button.Active = false
		button.BackgroundColor3 = Theme.PanelLight
		button.TextColor3 = Theme.SubText
		if stroke then
			stroke.Transparency = 0.85
		end
	elseif state == "Danger" then
		if gradient then
			gradient.Enabled = false
		end
		button.Active = true
		button.BackgroundColor3 = Theme.Danger
		button.TextColor3 = Color3.new(1, 1, 1)
		if stroke then
			stroke.Color = Color3.fromRGB(255, 210, 210)
			stroke.Transparency = 0.5
		end
	end
end

-- Builds a rounded, gold-gradient progress-bar track + fill inside `container`
-- and returns a setter you call with a 0..1 fraction to animate the fill.
function UIFactory.ProgressBar(container: Frame, initialFraction: number?): (Frame, (fraction: number) -> ())
	local track = UIFactory.Frame({
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = Theme.Panel,
		Parent = container,
	})
	UIFactory.Corner(5).Parent = track
	local trackStroke = Instance.new("UIStroke")
	trackStroke.Color = Theme.PanelLight
	trackStroke.Thickness = 1
	trackStroke.Transparency = 0.3
	trackStroke.Parent = track

	local fill = UIFactory.Frame({
		Size = UDim2.new(math.clamp(initialFraction or 0, 0, 1), 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		Parent = track,
	})
	UIFactory.Corner(5).Parent = fill
	UIFactory.Gradient(ColorSequence.new(Theme.AccentPale, Theme.Violet), 0).Parent = fill

	local function setFraction(fraction: number)
		fraction = math.clamp(fraction, 0, 1)
		TweenService:Create(fill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = UDim2.new(fraction, 0, 1, 0) }):Play()
	end

	return track, setFraction
end

-- A full-bleed backdrop gradient dropped in first so it sits behind everything
-- else in the ScreenGui, giving the whole game a warm cream-to-blush backdrop.
function UIFactory.Backdrop(screenGui: ScreenGui): Frame
	local backdrop = UIFactory.Frame({
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Theme.Background,
		ZIndex = 0,
		Parent = screenGui,
	})
	UIFactory.Gradient(ColorSequence.new(Theme.BackgroundTop, Theme.Background), 135).Parent = backdrop
	return backdrop
end

return UIFactory
