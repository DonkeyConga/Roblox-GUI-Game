--!strict
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local RemoteController = require(script.Parent.RemoteController)
local MainUI = require(script.Parent.UI.MainUI)
local OverheadTitle = require(script.Parent.UI.OverheadTitle)

-- Replaced by the themed Leaderboard tab in MainUI — pcall'd since
-- SetCoreGuiEnabled can occasionally throw if called too early.
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
end)

MainUI.Init(player, RemoteController)
OverheadTitle.Init(Players)
