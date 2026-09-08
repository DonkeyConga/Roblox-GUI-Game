--!strict
-- Toast notifications stacked top-right, auto-fading after a few seconds.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UIFactory = require(ReplicatedStorage.Shared.UIFactory)

local Notification = {}
local Theme = UIFactory.Theme

function Notification.Create(screenGui: ScreenGui)
	local container = UIFactory.Frame({
		Size = UDim2.new(0, 320, 1, -80),
		Position = UDim2.new(1, -336, 0, 70),
		BackgroundTransparency = 1,
		ZIndex = 60,
		Parent = screenGui,
	})
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.Parent = container

	local colorByType = {
		Success = Theme.Success,
		Danger = Theme.Danger,
		Info = Theme.Accent,
	}

	local api = {}

	function api.Show(message: string, kind: string?)
		local toast = UIFactory.Frame({
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = colorByType[kind or "Info"] or Theme.Accent,
			ZIndex = 60,
			Parent = container,
		})
		UIFactory.Corner(10).Parent = toast
		UIFactory.Padding(10).Parent = toast

		UIFactory.Label({
			Text = message,
			TextWrapped = true,
			TextColor3 = Color3.new(1, 1, 1),
			Font = Theme.Font,
			TextSize = 14,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 60,
			Parent = toast,
		})

		task.delay(4, function()
			if not toast.Parent then
				return
			end
			local tween = TweenService:Create(toast, TweenInfo.new(0.3), { BackgroundTransparency = 1 })
			tween:Play()
			tween.Completed:Wait()
			toast:Destroy()
		end)
	end

	return api
end

return Notification
