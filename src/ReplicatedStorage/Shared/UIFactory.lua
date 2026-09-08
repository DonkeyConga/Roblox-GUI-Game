--!strict
-- Shared visual theme + small helpers so every panel looks consistent
-- without copy-pasting corner/stroke/padding/button boilerplate everywhere.
local TweenService = game:GetService("TweenService")

local UIFactory = {}

UIFactory.Theme = {
	Background = Color3.fromRGB(24, 24, 32),
	Panel = Color3.fromRGB(32, 32, 44),
	PanelLight = Color3.fromRGB(44, 44, 60),
	Accent = Color3.fromRGB(90, 140, 255),
	Success = Color3.fromRGB(80, 200, 120),
	Danger = Color3.fromRGB(230, 80, 80),
	Text = Color3.fromRGB(240, 240, 245),
	SubText = Color3.fromRGB(170, 170, 185),
	Font = Enum.Font.GothamBold,
	FontRegular = Enum.Font.Gotham,
}

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
	corner.CornerRadius = UDim.new(0, radius or 10)
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

function UIFactory.Frame(props: { [string]: any }?): Frame
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = UIFactory.Theme.Panel
	frame.BorderSizePixel = 0
	applyProps(frame, props)
	return frame
end

function UIFactory.Label(props: { [string]: any }?): TextLabel
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Font = UIFactory.Theme.FontRegular
	label.TextColor3 = UIFactory.Theme.Text
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	applyProps(label, props)
	return label
end

function UIFactory.Button(props: { [string]: any }?): TextButton
	local button = Instance.new("TextButton")
	button.BackgroundColor3 = UIFactory.Theme.Accent
	button.AutoButtonColor = false
	button.Font = UIFactory.Theme.Font
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 16
	button.BorderSizePixel = 0
	UIFactory.Corner(8).Parent = button

	local scale = Instance.new("UIScale")
	scale.Parent = button

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), { BackgroundTransparency = 0.15 }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.12), { BackgroundTransparency = 0 }):Play()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 1 }):Play()
	end)
	button.MouseButton1Down:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 0.94 }):Play()
	end)
	button.MouseButton1Up:Connect(function()
		TweenService:Create(scale, TweenInfo.new(0.08), { Scale = 1 }):Play()
	end)

	applyProps(button, props)
	return button
end

-- Builds a rounded progress-bar track + fill inside `container` and returns a
-- setter you call with a 0..1 fraction to animate the fill.
function UIFactory.ProgressBar(container: Frame, initialFraction: number?): (Frame, (fraction: number) -> ())
	local track = UIFactory.Frame({
		Size = UDim2.new(1, 0, 0, 10),
		BackgroundColor3 = UIFactory.Theme.PanelLight,
		Parent = container,
	})
	UIFactory.Corner(5).Parent = track

	local fill = UIFactory.Frame({
		Size = UDim2.new(math.clamp(initialFraction or 0, 0, 1), 0, 1, 0),
		BackgroundColor3 = UIFactory.Theme.Accent,
		Parent = track,
	})
	UIFactory.Corner(5).Parent = fill

	local function setFraction(fraction: number)
		fraction = math.clamp(fraction, 0, 1)
		TweenService:Create(fill, TweenInfo.new(0.25), { Size = UDim2.new(fraction, 0, 1, 0) }):Play()
	end

	return track, setFraction
end

return UIFactory
